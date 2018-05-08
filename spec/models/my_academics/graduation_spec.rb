describe MyAcademics::Graduation do
  def student_plan(grad_term_id, grad_term_name, plan = nil, program = nil, is_active = true)
    {
      'expectedGraduationTerm' => {
        'id' => grad_term_id,
        'name' => grad_term_name
      },
      'statusInPlan' => {
        'status' => {
          'code' => is_active ? 'AC' : nil
        }
      },
      'academicPlan' => {
        'plan' => {
          'description' => plan
        },
        'academicProgram' => {
          'program' => {
            'code' => program
          }
        }
      }
    }
  end
  def career(code, role)
    {'code' => code, :role => role}
  end

  let(:uid) { random_id }
  let(:student_id) { random_id }
  let(:academic_statuses) {[ugrd_career_academic_status, grad_career_academic_status, law_career_academic_status]}
  let(:ugrd_career_academic_status) do
    {
      'studentPlans' => [
        student_plan('2205', '2020 Summer')
      ],
      'studentCareer' => career('UGRD', 'ugrd')
    }
  end
  let(:ugrd_career_academic_status_multiple) do
    {
      'studentPlans' => [
        student_plan('2205', '2020 Summer'),
        student_plan('2212', '2021 Spring')
      ],
      'studentCareer' => career('UGRD', 'ugrd')
    }
  end
  let(:ugrd_career_inactive_academic_status) do
    {
      'studentPlans' => [
        student_plan(grad_term_id = '2225', grad_term_name = '2022 Summer', plan = nil, program = nil, is_active = false)
      ],
      'studentCareer' => career('UGRD', 'ugrd')
    }
  end
  let(:grad_career_academic_status) do
    {
      'studentPlans' => [
        student_plan(grad_term_id = '2182', grad_term_name = '2018 fall', plan = 'Guitar Hero', program = 'Slash Institute of Shredding', is_active = true)
      ],
      'studentCareer' => career('GRAD', 'grad')
    }
  end
  let(:law_career_academic_status) do
    {
      'studentPlans' => [
        student_plan(grad_term_id = '2207', grad_term_name = '2020 Fall', plan = 'Business Admin MBA-JD CDP', program = 'LACAD', is_active = true),
        student_plan(grad_term_id = '2207', grad_term_name = '2020 Fall', plan = 'Law JD-MBA CDP', program = 'LACAD', is_active = true),
        student_plan(grad_term_id = '2217', grad_term_name = '2021 Fall', plan = 'Super Duper Lawyer Man', program = 'Superhero Lawyer Hybrids', is_active = true)
      ],
      'studentCareer' => career('LAW', 'law')
    }
  end
  let(:enrollment_terms) do
    [
      {:termId=>'2168', :termDescr=>'2016 Fall', :acadCareer=>'UGRD'},
      {:termId=>'2172', :termDescr=>'2017 Spring', :acadCareer=>'UGRD'},
      {:termId=>'2175', :termDescr=>'2017 Summer', :acadCareer=>'UGRD'}
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
    [{:id=>'phase1'}, {:id=>'phase2'}, {:id=>'adjust'}]
  end
  let(:spring_2017_enrollment_periods) do
    [{:id=>'phase1'}, {:id=>'phase2'}, {:id=>'adjust'}]
  end
  let(:summer_2017_enrollment_periods) do
    [{:id=>'phase1'}, {:id=>'phase2'}, {:id=>'adjust'}]
  end


  subject { MyAcademics::Graduation.new(uid) }

  before do
    allow_any_instance_of(HubEdos::UserAttributes).to receive(:has_role?).and_return(true)
    allow_any_instance_of(MyAcademics::MyAcademicStatus).to receive(:get_feed).and_return({:feed=> { 'student'=> { 'academicStatuses'=> academic_statuses } } })
    allow(EdoOracle::Queries).to receive(:get_concurrent_student_status).and_return({ 'concurrent_status' => 'N' })
    allow(CampusSolutions::MyEnrollmentTerms).to receive(:get_terms).and_return(enrollment_terms)
    allow(CampusSolutions::MyEnrollmentTerm).to receive(:get_term) do |uid, term_id|
      enrollment_terms_to_term_map[term_id]
    end
  end

  context 'merge' do
    it 'adds feed data to hash, ignoring graduate careers' do
      my_academics_feed = {}
      result = subject.merge(my_academics_feed)
      expect(result[:graduation][:undergraduate][:expectedGraduationTerm][:termId]).to eq '2205'
      expect(result[:graduation][:undergraduate][:expectedGraduationTerm][:termName]).to eq 'Summer 2020'
      expect(result[:graduation][:undergraduate][:activeTermsWithEnrollmentAppointments]).to eq ['2168', '2172', '2175']
      expect(result[:graduation][:undergraduate][:appointmentsInGraduatingTerm]).to eq false
      result[:graduation][:gradLaw][:expectedGraduationTerms].should have(2).items
      result[:graduation][:gradLaw][:expectedGraduationTerms][0][:plans].should include 'Business Admin MBA-JD CDP'
    end
  end

  context 'concurrency' do
    context 'concurrent students' do
      before do
        EdoOracle::Queries.stub(:get_concurrent_student_status) { { 'concurrent_status' => 'Y' } }
      end
      it 'adds graduate careers' do
        result = subject.get_feed
        result[:gradLaw][:expectedGraduationTerms].should have(3).items
        result[:gradLaw][:expectedGraduationTerms][0][:plans].should include 'Guitar Hero'
      end
    end
    context 'non-concurrent students' do
      before do
        EdoOracle::Queries.stub(:get_concurrent_student_status) { { 'concurrent_status' => 'N' } }
      end
      it 'removes graduate careers' do
        result = subject.get_feed
        result[:gradLaw][:expectedGraduationTerms].should have(2).items
        result[:gradLaw][:expectedGraduationTerms][0][:plans].should include 'Law JD-MBA CDP'
      end
    end
  end

  context 'last expected graduation term' do
    context 'when only single academic career status' do
      let(:academic_statuses) { [ugrd_career_academic_status] }
      it 'returns latest expected graduation term' do
        result = subject.get_feed
        expect(result[:undergraduate][:expectedGraduationTerm][:termId]).to eq '2205'
        expect(result[:undergraduate][:expectedGraduationTerm][:termName]).to eq 'Summer 2020'
      end
    end
    context 'when multiple academic career statuses' do
      let(:academic_statuses) { [ugrd_career_academic_status_multiple] }
      it 'returns latest expected graduation term' do
        result = subject.get_feed
        expect(result[:undergraduate][:expectedGraduationTerm][:termId]).to eq '2212'
        expect(result[:undergraduate][:expectedGraduationTerm][:termName]).to eq 'Spring 2021'
      end
    end
    context 'when student has an inactive plan' do
      let(:academic_statuses) { [ugrd_career_inactive_academic_status, ugrd_career_academic_status_multiple] }
      it 'does not include the inactive plan in determining latest expected graduation term' do
        result = subject.get_feed
        expect(result[:undergraduate][:expectedGraduationTerm][:termId]).to eq '2212'
        expect(result[:undergraduate][:expectedGraduationTerm][:termName]).to eq 'Spring 2021'
      end
    end
  end

  context 'active terms with enrollment appointments' do
    context 'when no active enrollment terms' do
      let(:enrollment_terms) { [] }
      it 'returns no term codes' do
        result = subject.get_feed
        expect(result[:undergraduate][:activeTermsWithEnrollmentAppointments].count).to eq 0
      end
    end
    context 'when all enrollment terms have appointments' do
      it 'returns all term codes' do
        result = subject.get_feed
        expect(result[:undergraduate][:activeTermsWithEnrollmentAppointments]).to eq ['2168', '2172', '2175']
      end
    end
    context 'when some enrollment terms have appointments' do
      let(:summer_2017_enrollment_periods) { [] }
      it 'returns some term codes' do
        result = subject.get_feed
        expect(result[:undergraduate][:activeTermsWithEnrollmentAppointments]).to eq ['2168', '2172']
      end
    end
  end

  context 'indicating if student has enrollment appointments in their expected graduation term' do
    subject { MyAcademics::Graduation.new(uid).appointments_in_graduating_term(last_expected_graduation_term, terms_with_appointments) }
    context 'when no enrollment appointments in expected graduation term' do
      let(:last_expected_graduation_term) { {:termId=>'2178', :termName=>'Fall 2017'} }
      let(:terms_with_appointments) { ['2172', '2175'] }
      it 'returns false' do
        expect(subject).to eq false
      end
    end
    context 'when enrollment appointments in expected graduation term are present' do
      let(:last_expected_graduation_term) { {:termId=>'2178', :termName=>'Fall 2017'} }
      let(:terms_with_appointments) { ['2175', '2178'] }
      it 'returns true' do
        expect(subject).to eq true
      end
    end
  end

end
