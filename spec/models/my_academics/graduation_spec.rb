describe MyAcademics::Graduation do
  def student_plan(grad_term_id, grad_term_name)
    {
      'expectedGraduationTerm' => {
        'id' => grad_term_id,
        'name' => grad_term_name
      },
      'statusInPlan' => {
        'status' => {
          'code' => 'AC'
        }
      }
    }
  end

  let(:uid) { random_id }
  let(:student_id) { random_id }
  let(:academic_statuses) do
    [
      {
        "studentPlans" => [
          student_plan('2202', '2020 Spring'),
          student_plan('2205', '2020 Summer'),
        ]
      },
      second_career_academic_status
    ].compact
  end
  let(:second_career_academic_status) do
    {
      "studentPlans" => [
        student_plan('2207', '2020 Fall')
      ]
    }
  end
  let(:enrollment_terms) do
    [
      {:termId=>"2168", :termDescr=>"2016 Fall", :acadCareer=>"UGRD"},
      {:termId=>"2172", :termDescr=>"2017 Spring", :acadCareer=>"UGRD"},
      {:termId=>"2175", :termDescr=>"2017 Summer", :acadCareer=>"UGRD"}
    ]
  end
  let(:enrollment_terms_to_term_map) do
    {
      '2168' => {
        studentId: student_id,
        enrollmentPeriod: fall_2016_enrollment_periods
      },
      '2172' => {
        studentId: student_id,
        enrollmentPeriod: spring_2017_enrollment_periods
      },
      '2175' => {
        studentId: student_id,
        enrollmentPeriod: summer_2017_enrollment_periods
      },
    }
  end
  let(:fall_2016_enrollment_periods) do
    [{:id=>"phase1"}, {:id=>"phase2"}, {:id=>"adjust"}]
  end
  let(:spring_2017_enrollment_periods) do
    [{:id=>"phase1"}, {:id=>"phase2"}, {:id=>"adjust"}]
  end
  let(:summer_2017_enrollment_periods) do
    [{:id=>"phase1"}, {:id=>"phase2"}, {:id=>"adjust"}]
  end
  let(:careers) do
    [
      {"code"=>"UGRD", "description"=>"Undergraduate"},
      {"code"=>"GRAD", "description"=>"Graduate"},
      {"code"=>"LAW", "description"=>"Law"},
    ]
  end

  subject { MyAcademics::Graduation.new(uid) }

  before do
    allow_any_instance_of(HubEdos::UserAttributes).to receive(:has_role?).and_return(true)
    allow(HubEdos::MyAcademicStatus).to receive(:get_statuses).and_return(academic_statuses)
    allow(CampusSolutions::MyEnrollmentTerms).to receive(:get_terms).and_return(enrollment_terms)
    allow(CampusSolutions::MyEnrollmentTerm).to receive(:get_term) do |uid, term_id|
      enrollment_terms_to_term_map[term_id]
    end
    allow(HubEdos::MyAcademicStatus).to receive(:get_careers).and_return(careers)
  end

  context 'merge' do
    it 'adds feed data to hash' do
      my_academics_feed = {}
      result = subject.merge(my_academics_feed)
      expect(result[:graduation][:lastExpectedGraduationTerm][:code]).to eq '2207'
      expect(result[:graduation][:lastExpectedGraduationTerm][:name]).to eq 'Fall 2020'
      expect(result[:graduation][:activeTermsWithEnrollmentAppointments]).to eq ["2168", "2172", "2175"]
      expect(result[:graduation][:isNotGraduateOrLawStudent]).to eq false
      expect(result[:graduation][:appointmentsInGraduatingTerm]).to eq false
    end
  end

  context 'last expected graduation term' do
    context 'when only single academic career status' do
      let(:second_career_academic_status) { nil }
      it 'returns latest expected graduation term' do
        result = subject.get_feed
        expect(result[:lastExpectedGraduationTerm][:code]).to eq '2205'
        expect(result[:lastExpectedGraduationTerm][:name]).to eq 'Summer 2020'
      end
    end
    context 'when multiple acdemic career statuses' do
      it 'returns latest expected graduation term' do
        result = subject.get_feed
        expect(result[:lastExpectedGraduationTerm][:code]).to eq '2207'
        expect(result[:lastExpectedGraduationTerm][:name]).to eq 'Fall 2020'
      end
    end
  end

  context 'active terms with enrollment appointments' do
    context 'when no active enrollment terms' do
      let(:enrollment_terms) { [] }
      it 'returns no term codes' do
        result = subject.get_feed
        expect(result[:activeTermsWithEnrollmentAppointments].count).to eq 0
      end
    end
    context 'when all enrollment terms have appointments' do
      it 'returns all term codes' do
        result = subject.get_feed
        expect(result[:activeTermsWithEnrollmentAppointments]).to eq ["2168", "2172", "2175"]
      end
    end
    context 'when some enrollment terms have appointments' do
      let(:summer_2017_enrollment_periods) { [] }
      it 'returns some term codes' do
        result = subject.get_feed
        expect(result[:activeTermsWithEnrollmentAppointments]).to eq ["2168", "2172"]
      end
    end
  end

  context 'is not graduate or law career student' do
    subject { MyAcademics::Graduation.new(uid).get_feed.try(:[], :isNotGraduateOrLawStudent) }
    context 'when no careers present' do
      let(:careers) { [] }
    end
    context 'when graduate career present' do
      let(:careers) do
        [
          {"code"=>"UGRD", "description"=>"Undergraduate"},
          {"code"=>"GRAD", "description"=>"Graduate"},
        ]
      end
      it 'returns false' do
        expect(subject).to eq false
      end
    end
    context 'when law career present' do
      let(:careers) do
        [
          {"code"=>"UGRD", "description"=>"Undergraduate"},
          {"code"=>"LAW", "description"=>"Law"},
        ]
      end
      it 'returns false' do
        expect(subject).to eq false
      end
    end
    context 'when no law or graduate career present' do
      let(:careers) { [{"code"=>"UGRD", "description"=>"Undergraduate"}] }
      it 'returns true' do
        expect(subject).to eq true
      end
    end
  end

  context 'indicating if student has enrollment appointments in their expected graduation term' do
    subject { MyAcademics::Graduation.new(uid).appointmentsInGraduatingTerm(last_expected_graduation_term, terms_with_appointments) }
    context 'when no enrollment appointments in expected graduation term' do
      let(:last_expected_graduation_term) { {:code=>"2178", :name=>"Fall 2017"} }
      let(:terms_with_appointments) { ['2172', '2175'] }
      it 'returns false' do
        expect(subject).to eq false
      end
    end
    context 'when enrollment appointments in expected graduation term are present' do
      let(:last_expected_graduation_term) { {:code=>"2178", :name=>"Fall 2017"} }
      let(:terms_with_appointments) { ['2175', '2178'] }
      it 'returns true' do
        expect(subject).to eq true
      end
    end
  end

end
