describe MyAcademics::AcademicPlan do

  let(:uid) { random_id }
  let(:user_cs_id) { random_id }
  let(:fake) { true }

  let(:plan_proxy) { CampusSolutions::AdvisingAcademicPlan.new(user_id: uid, fake: fake) }
  let(:semesters_data) {
    { semesters: [
      {
        :name => 'Fall 2016',
        :slug => 'fall-2016',
        :termCode => 'D',
        :termYear => '2016',
        :timeBucket => 'current',
        :campusSolutionsTerm => true,
        :gradingInProgress => nil,
        :classes => [
          {
            course_code: 'EDUC 75AC',
            sections: [
              {
                is_primary_section: true,
                units: '3.0'
              },
              {
                is_primary_section: false,
                units: '3.0'
              }]

          }],
        :hasEnrollmentData => true,
        :summaryFromTranscript => false,
        :hasEnrolledClasses => true
      },
      {
        :name => 'Fall 2017',
        :slug => 'fall-2017',
        :termCode => 'D',
        :termYear => '2017',
        :timeBucket => 'future',
        :campusSolutionsTerm => true,
        :gradingInProgress => nil,
        :classes => [
          {
            course_code: 'INTEGBI C82',
            sections: [
              {
                is_primary_section: true,
                waitlisted: true,
                units: '4.0',
                waitlistPosition: '3'
              }]
          },
          {
            course_code: 'EDUC 75AC',
            sections: [
              {
                is_primary_section: true,
                units: '2.0'
              },
              {
                is_primary_section: true,
                units: '3.0'
              }
            ]
          }],
        :hasEnrollmentData => true,
        :summaryFromTranscript => false,
        :hasEnrolledClasses => true
      }
    ]
    }
  }

  before do
    allow(CampusSolutions::AdvisingAcademicPlan).to receive(:get).and_return(plan_proxy)
    allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: uid).and_return(
      double(lookup_campus_solutions_id: user_cs_id))
  end

  subject do
    semesters_data.tap {|x| MyAcademics::AcademicPlan.new(uid).merge(x)}
  end

  context 'when grading returns statuses for a teaching semester' do

    it 'it should combine the planned and enrolled semesters sorted' do
      expect(subject[:planSemesters].length).to eq 3
      expect(subject[:planSemesters][0][:edoId]).to eq '2168'
      expect(subject[:planSemesters][1][:edoId]).to eq '2172'
      expect(subject[:planSemesters][2][:edoId]).to eq '2178'
    end

    it 'it should parse enrolled semesters correctly' do
      expect(subject[:planSemesters][0][:enrolledClasses].length).to eq 1
      expect(subject[:planSemesters][1][:enrolledClasses]).to be_nil
      expect(subject[:planSemesters][2][:enrolledClasses].length).to eq 2
    end

    it 'it should parse planned semesters correctly' do
      expect(subject[:planSemesters][0][:plannedClasses].length).to eq 1
      expect(subject[:planSemesters][1][:plannedClasses].length).to eq 2
      expect(subject[:planSemesters][2][:plannedClasses].length).to eq 0
    end

    it 'it should parse hasWaitlisted flag  correctly' do
      expect(subject[:planSemesters][0][:hasWaitlisted]).to eq false
      expect(subject[:planSemesters][1][:hasWaitlisted]).to eq false
      expect(subject[:planSemesters][2][:hasWaitlisted]).to eq true
    end

    it 'it should calc plannedUnits correctly' do
      expect(subject[:planSemesters][0][:plannedUnits]).to eq '3.0'
      expect(subject[:planSemesters][1][:plannedUnits]).to eq '7.0'
      expect(subject[:planSemesters][2][:plannedUnits]).to eq '0.0'
    end

    it 'it should calc enrolledUnits correctly' do
      expect(subject[:planSemesters][0][:enrolledUnits]).to eq '3.0'
      expect(subject[:planSemesters][1][:enrolledUnits]).to eq '0.0'
      expect(subject[:planSemesters][2][:enrolledUnits]).to eq '5.0'
    end

    it 'it should calc waitlistedunits correctly' do
      expect(subject[:planSemesters][0][:waitlistedUnits]).to eq '0.0'
      expect(subject[:planSemesters][1][:waitlistedUnits]).to eq '0.0'
      expect(subject[:planSemesters][2][:waitlistedUnits]).to eq '4.0'
    end

  end

end
