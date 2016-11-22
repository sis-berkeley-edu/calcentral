describe MyAcademics::FacultyDelegate do

  let(:term_id) { random_id }
  let(:course_id) { random_id }
  let(:fake) { true }

  let(:semesters_data) {
    { teachingSemesters: [
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
                units: '3.0',
                instructors: [
                  {
                    uid: '238382'
                  },
                  {
                    uid: '904715'
                  }
                ]
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

  subject do
    semesters_data.tap {|x|MyAcademics::FacultyDelegate.new(term_id: term_id, course_id: course_id).merge(x)}
  end

  context 'when grading returns statuses for a teaching semester' do
    let(:uid) { '238382' }
    let(:delegate_proxy) { CampusSolutions::FacultyDelegate.new(term_id: term_id, course_id: course_id, fake: fake) }

    before do
      allow(CampusSolutions::FacultyDelegate).to receive(:new).and_return(delegate_proxy)
      allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: uid).and_return(
        double(lookup_campus_solutions_id: '25738808'))
      allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: '904715').and_return(
        double(lookup_campus_solutions_id: '10113922'))
    end

    it 'it should return expected values merged into section' do
      instructor_data = subject[:teachingSemesters][0][:classes][0][:sections][0]
      expect(instructor_data[:instructors][0][:csGradeAccessCode]).to eq 'A'
      expect(instructor_data[:instructors][0][:csDelegatRole]).to eq :PI
      expect(instructor_data[:instructors][0][:ccGradingAccees]).to eq :approveGrades
      expect(instructor_data[:instructors][0][:ccDelegateRole]).to eq 'Instr. of Record'
      expect(instructor_data[:instructors][0][:ccDelegateRoleOrder]).to eq 1

      expect(instructor_data[:instructors][1][:csGradeAccessCode]).to eq 'G'
      expect(instructor_data[:instructors][1][:csDelegatRole]).to eq :APRX
      expect(instructor_data[:instructors][1][:ccGradingAccees]).to eq :enterGrades
      expect(instructor_data[:instructors][1][:ccDelegateRole]).to eq 'Proxy'
      expect(instructor_data[:instructors][1][:ccDelegateRoleOrder]).to eq 3
    end

  end
end
