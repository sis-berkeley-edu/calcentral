describe MyAcademics::FacultyDelegate do
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
                    uid: '238382',
                    role: 'PI',
                    gradeRosterAccess: 'A'
                  },
                  {
                    uid: '904715',
                    role: 'APRX',
                    gradeRosterAccess: 'G'
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
    semesters_data.tap {|x| MyAcademics::FacultyDelegate.new(user_id: uid).merge(x)}
  end

  context 'when grading returns statuses for a teaching semester' do
    let(:uid) { '238382' }

    it 'it should return expected values merged into section' do
      instructor_data = subject[:teachingSemesters][0][:classes][0][:sections][0]
      expect(instructor_data[:instructors][0][:csGradeAccessCode]).to eq 'A'
      expect(instructor_data[:instructors][0][:csDelegateRole]).to eq :PI
      expect(instructor_data[:instructors][0][:ccGradingAccess]).to eq :approveGrades
      expect(instructor_data[:instructors][0][:ccDelegateRole]).to eq 'Instr. of Record'
      expect(instructor_data[:instructors][0][:ccDelegateRoleOrder]).to eq 1

      expect(instructor_data[:instructors][1][:csGradeAccessCode]).to eq 'G'
      expect(instructor_data[:instructors][1][:csDelegateRole]).to eq :APRX
      expect(instructor_data[:instructors][1][:ccGradingAccess]).to eq :enterGrades
      expect(instructor_data[:instructors][1][:ccDelegateRole]).to eq 'Proxy'
      expect(instructor_data[:instructors][1][:ccDelegateRoleOrder]).to eq 3
    end

  end
end
