describe Rosters::Campus do
  let(:term_yr) {'2014'}
  let(:term_cd) {'B'}
  let(:cs_term_id) {'2142'}
  let(:term_slug) {"#{term_yr}-#{term_cd}"}
  let(:user_id) {rand(99999).to_s}
  let(:student_user_id) {rand(99999).to_s}
  let(:ccn1) {rand(9999)}
  let(:ccn2) {rand(9999)}
  let(:ccn3) {rand(9999)}
  let(:ccn4) {rand(9999)}
  let(:enrolled_student_login_id) {rand(99999).to_s}
  let(:enrolled_student_student_id) {rand(99999).to_s}
  let(:waitlisted_student_login_id) {rand(99999).to_s}
  let(:waitlisted_student_student_id) {rand(99999).to_s}
  let(:another_enrolled_login_id) { random_id }
  let(:another_enrolled_student_id) { random_cs_id }
  let(:catid) {"#{rand(999)}"}
  let(:campus_course_id) {"info-#{catid}-#{term_slug}"}
  let(:fake_campus) do
    {
      "#{term_slug}" => [
        {
          id: campus_course_id,
          term_yr: term_yr,
          term_cd: term_cd,
          catid: catid,
          dept: 'INFO',
          course_code: "INFO #{catid}",
          emitter: 'Campus',
          name: 'Data Rules Everything Around Me',
          role: 'Instructor',
          sections: [
            {
              ccn: ccn1,
              section_label: 'LEC 001',
              section_number: '001',
              instruction_format: 'LEC',
              is_primary_section: true,
              enroll_limit: 650,
              waitlist_limit: 110,
              schedules: {
                recurring: [
                  {
                    buildingName: 'Soda',
                    roomNumber: '100',
                    schedule: 'TuTh 3:00P-3:59P'
                  },
                  {
                    buildingName: 'Soda',
                    roomNumber: '102',
                    schedule: 'Fr 11:00A-11:59A'
                  }
                ]
              }
            },
            {
              ccn: ccn2,
              section_label: 'LAB 001',
              section_number: '001',
              instruction_format: 'LAB',
              is_primary_section: false,
              enroll_limit: 4,
              waitlist_limit: 2,
              schedules: {
                recurring: [
                  {
                    buildingName: 'Hertz',
                    roomNumber: '320',
                    schedule: 'MoFr 1:00P-1:59P'
                  }
                ]
              }
            },
            {
              ccn: ccn3,
              section_label: 'LAB 002',
              section_number: '003',
              instruction_format: 'LAB',
              is_primary_section: false,
              enroll_limit: 3,
              waitlist_limit: 2,
              schedules: {
                recurring: [
                  {
                    buildingName: 'Hertz',
                    roomNumber: '450',
                    schedule: 'MoFr 1:00P-1:59P'
                  }
                ]
              }
            }
          ]
        }
      ]
    }
  end

  shared_examples 'a good and proper roster' do
    let(:model) { Rosters::Campus.new(user_id, course_id: campus_course_id) }
    let(:feed) { model.get_feed }

    it 'should include course data' do
      expect(feed[:campus_course][:id]).to eq campus_course_id
      expect(feed[:campus_course][:name]).to eq fake_campus["#{term_slug}"][0][:name]
    end

    it 'should include section statistics' do
      expect(feed[:sections].length).to eq 3
      expect(feed[:sections][0][:ccn]).to eq ccn1
      expect(feed[:sections][0][:name]).to eq "INFO #{catid} LEC 001"
      expect(feed[:sections][0][:section_label]).to eq "LEC 001"
      expect(feed[:sections][0][:section_number]).to eq "001"
      expect(feed[:sections][0][:instruction_format]).to eq "LEC"
      expect(feed[:sections][0][:dates]).to eq ['TuTh 3:00P-3:59P', 'Fr 11:00A-11:59A']
      expect(feed[:sections][0][:locations]).to eq ['100 Soda', '102 Soda']
      expect(feed[:sections][0][:is_primary]).to eq true
      expect(feed[:sections][0][:enroll_limit]).to eq 650
      expect(feed[:sections][0][:enroll_open]).to eq 648
      expect(feed[:sections][0][:enroll_count]).to eq 2
      expect(feed[:sections][0][:waitlist_limit]).to eq 110
      expect(feed[:sections][0][:waitlist_open]).to eq 109
      expect(feed[:sections][0][:waitlist_count]).to eq 1
      expect(feed[:sections][1][:ccn]).to eq ccn2
      expect(feed[:sections][1][:name]).to eq "INFO #{catid} LAB 001"
      expect(feed[:sections][1][:section_label]).to eq "LAB 001"
      expect(feed[:sections][1][:section_number]).to eq "001"
      expect(feed[:sections][1][:instruction_format]).to eq "LAB"
      expect(feed[:sections][1][:dates]).to eq ['MoFr 1:00P-1:59P']
      expect(feed[:sections][1][:locations]).to eq ['320 Hertz']
      expect(feed[:sections][1][:is_primary]).to eq false
      expect(feed[:sections][1][:enroll_limit]).to eq 4
      expect(feed[:sections][1][:enroll_open]).to eq 2
      expect(feed[:sections][1][:enroll_count]).to eq 2
      expect(feed[:sections][1][:waitlist_limit]).to eq 2
      expect(feed[:sections][1][:waitlist_open]).to eq 1
      expect(feed[:sections][1][:waitlist_count]).to eq 1
    end

    it 'should return a list of officially enrolled students for a course ccn' do
      expect(feed[:students].length).to eq 3
      student = feed[:students][0]
      expect(student[:id]).to eq enrolled_student_login_id
      expect(student[:student_id]).to eq enrolled_student_student_id
      expect(student[:first_name]).to be_present
      expect(student[:last_name]).to be_present
      expect(student[:email]).to be_present
      expect(student[:sections].length).to eq 2
      expect(student[:sections][0][:ccn]).to eq ccn1
      expect(student[:sections][0][:name]).to eq "INFO #{catid} LEC 001"
      expect(student[:sections][1][:ccn]).to eq ccn2
      expect(student[:sections][1][:name]).to eq "INFO #{catid} LAB 001"
      expect(student[:profile_url]).to be_present
    end

    it 'should show official photo links for students who are not waitlisted in all sections' do
      expect(feed[:sections].length).to eq 3
      expect(feed[:students].length).to eq 3
      expect(feed[:students].index {|student| student[:id] == waitlisted_student_login_id &&
        student[:photo].nil?
      }).to_not be_nil
    end
  end

  context 'a course with two sections' do
    before do
      expect(Berkeley::Terms).to receive(:legacy?).at_least(1).times.and_return is_legacy
      allow(CampusOracle::UserCourses::All).to receive(:new).with(user_id: user_id).and_return(double(get_all_campus_courses: fake_oracle))
      allow(EdoOracle::UserCourses::All).to receive(:new).with(user_id: user_id).and_return(double(get_all_campus_courses: fake_edo))
    end

    context 'two-section course from legacy data' do
      let(:is_legacy) { true }
      let(:fake_oracle) { fake_campus }
      let(:fake_edo) { {} }
      before do
        expect(CampusOracle::Queries).to receive(:get_enrolled_students_for_ccns).with([ccn1, ccn2, ccn3], term_yr, term_cd).and_return(fake_enrollments)
      end
      let(:fake_enrollments) do
        [
          {
            'course_cntl_num' => ccn1,
            'ldap_uid' => enrolled_student_login_id,
            'enroll_status' => 'E',
            'student_id' => enrolled_student_student_id,
            'first_name' => 'First Name',
            'last_name' => 'Last Name',
            'student_email_address' => "#{enrolled_student_login_id}@example.com",
          },
          {
            'course_cntl_num' => ccn1,
            'ldap_uid' => waitlisted_student_login_id,
            'enroll_status' => 'W',
            'student_id' => waitlisted_student_student_id,
            'first_name' => 'First Name',
            'last_name' => 'Last Name',
            'student_email_address' => "#{waitlisted_student_login_id}@example.com",
          },
          {
            'course_cntl_num' => ccn1,
            'ldap_uid' => another_enrolled_login_id,
            'enroll_status' => 'E',
            'student_id' => another_enrolled_student_id,
            'first_name' => 'First Name',
            'last_name' => 'Last Name',
            'student_email_address' => "#{another_enrolled_login_id}@example.com",
          },
          {
            'course_cntl_num' => ccn2,
            'ldap_uid' => enrolled_student_login_id,
            'enroll_status' => 'E',
            'student_id' => enrolled_student_student_id,
            'first_name' => 'First Name',
            'last_name' => 'Last Name',
            'student_email_address' => "#{enrolled_student_login_id}@example.com",
          },
          {
            'course_cntl_num' => ccn2,
            'ldap_uid' => waitlisted_student_login_id,
            'enroll_status' => 'W',
            'student_id' => waitlisted_student_student_id,
            'first_name' => 'First Name',
            'last_name' => 'Last Name',
            'student_email_address' => "#{waitlisted_student_login_id}@example.com",
          },
          {
            'course_cntl_num' => ccn2,
            'ldap_uid' => another_enrolled_login_id,
            'enroll_status' => 'E',
            'student_id' => another_enrolled_student_id,
            'first_name' => 'First Name',
            'last_name' => 'Last Name',
            'student_email_address' => "#{another_enrolled_login_id}@example.com",
          }
        ]
      end
      it_should_behave_like 'a good and proper roster'
    end

    context 'two-section course from Campus Solutions data' do
      let(:is_legacy) { false }
      let(:term_id) { Berkeley::TermCodes.to_edo_id(term_yr, term_cd) }
      let(:fake_oracle) { {} }
      let(:fake_edo) { fake_campus }
      let(:feed) { feed = Rosters::Campus.new(user_id, course_id: campus_course_id).get_feed }

      context 'when enrollments are present' do
        before do
          expect(EdoOracle::Queries).to receive(:get_rosters).with([ccn1, ccn2, ccn3], term_id).and_return enrollments
          # A method rather than a let so that modifications during a test don't persist.
          def attributes
            [
              {
                ldap_uid: enrolled_student_login_id,
                student_id: enrolled_student_student_id,
                first_name: 'First Name',
                last_name: 'Last Name',
                email_address: "#{enrolled_student_login_id}@example.com"
              },
              {
                ldap_uid: waitlisted_student_login_id,
                student_id: waitlisted_student_student_id,
                first_name: 'First Name',
                last_name: 'Last Name',
                email_address: "#{waitlisted_student_login_id}@example.com"
              },
              {
                ldap_uid: another_enrolled_login_id,
                student_id: another_enrolled_student_id,
                first_name: 'Another Name',
                last_name: 'One Last Name',
                email_address: "#{another_enrolled_login_id}@example.com"
              }
            ]
          end
          expect(User::BasicAttributes).to receive(:attributes_for_uids)
            .with([enrolled_student_login_id, waitlisted_student_login_id, another_enrolled_login_id])
            .exactly(2).times.and_return(attributes, attributes)
        end
        let(:enrollments) do
          [
            {
              'section_id' => ccn1,
              'ldap_uid' => enrolled_student_login_id,
              'enroll_status' => 'E',
              'student_id' => enrolled_student_student_id,
              'grading_basis' => 'GRD',
              'units' => 4.0,
              'waitlist_position' => nil,
              'major' => 'Cognitive Science BA',
              'academic_career' => 'UGRD',
              'terms_in_attendance_group' => 'R2TA'
            },
            {
              'section_id' => ccn1,
              'ldap_uid' => enrolled_student_login_id,
              'enroll_status' => 'E',
              'student_id' => enrolled_student_student_id,
              'grading_basis' => 'GRD',
              'units' => 4.0,
              'waitlist_position' => nil,
              'major' => 'Computer Science BA',
              'academic_career' => 'UGRD',
              'terms_in_attendance_group' => 'R2TA'
            },
            {
              'section_id' => ccn1,
              'ldap_uid' => waitlisted_student_login_id,
              'enroll_status' => 'W',
              'student_id' => waitlisted_student_student_id,
              'grading_basis' => 'ESU',
              'units' => 3.0,
              'waitlist_position' => 9.0,
              'major' => 'Break Science BA',
              'academic_career' => 'UGRD',
              'terms_in_attendance_group' => 'R6TA'
            },
            {
              'section_id' => ccn1,
              'ldap_uid' => another_enrolled_login_id,
              'enroll_status' => 'E',
              'student_id' => another_enrolled_student_id,
              'grading_basis' => 'GRD',
              'units' => 4.0,
              'waitlist_position' => nil,
              'major' => 'Philosophy BA',
              'academic_career' => 'PHIL',
              'terms_in_attendance_group' => 'R2TA'
            },
            {
              'section_id' => ccn2,
              'ldap_uid' => enrolled_student_login_id,
              'enroll_status' => 'E',
              'student_id' => enrolled_student_student_id,
              'grading_basis' => 'GRD',
              'units' => 4.0,
              'waitlist_position' => nil,
              'major' => 'Computer Science BA',
              'academic_career' => 'UGRD',
              'terms_in_attendance_group' => 'R2TA'
            },
            {
              'section_id' => ccn2,
              'ldap_uid' => waitlisted_student_login_id,
              'enroll_status' => 'W',
              'student_id' => waitlisted_student_student_id,
              'grading_basis' => 'ESU',
              'units' => 3.0,
              'waitlist_position' => 9.0,
              'major' => 'Break Science BA',
              'academic_career' => 'UGRD',
              'terms_in_attendance_group' => 'R6TA'
            },
            {
              'section_id' => ccn2,
              'ldap_uid' => enrolled_student_login_id,
              'enroll_status' => 'E',
              'student_id' => enrolled_student_student_id,
              'grading_basis' => 'GRD',
              'units' => 4.0,
              'waitlist_position' => nil,
              'major' => 'Computer Science BA',
              'academic_career' => 'UGRD',
              'terms_in_attendance_group' => 'R2TA'
            },
            {
              'section_id' => ccn2,
              'ldap_uid' => another_enrolled_login_id,
              'enroll_status' => 'E',
              'student_id' => another_enrolled_student_id,
              'grading_basis' => 'GRD',
              'units' => 4.0,
              'waitlist_position' => nil,
              'major' => 'Philosophy BA',
              'academic_career' => 'PHIL',
              'terms_in_attendance_group' => 'R2TA'
            }
          ]
        end
        it_should_behave_like 'a good and proper roster'
        context 'when the number of enrollments exceeds the limit' do
          before do
            fake_campus[term_slug][0][:sections][0][:enroll_limit] = 1
          end
          it 'should report zero available enrollment spots' do
            expect(feed[:sections][0][:enroll_limit]).to eq 1
            expect(feed[:sections][0][:enroll_count]).to eq 2
            expect(feed[:sections][0][:enroll_open]).to eq 0
            expect(feed[:sections][0][:waitlist_count]).to eq 1
          end
        end

        it 'should translate additional enrollment data from section with grade component' do
          expect(feed[:students][0][:grade_option]).to eq 'Letter'
          expect(feed[:students][0][:units]).to eq '4.0'
          expect(feed[:students][0][:waitlist_position]).to be_nil
          expect(feed[:students][0][:academic_career]).to eq 'UGRD'
          expect(feed[:students][1][:grade_option]).to eq 'S/U'
          expect(feed[:students][1][:units]).to eq '3.0'
          expect(feed[:students][1][:waitlist_position]).to eq 9
          expect(feed[:students][1][:academic_career]).to eq 'UGRD'
        end
        it 'should include majors and terms in attendance count' do
          expect(feed[:students][0][:majors][0]).to eq 'Cognitive Science BA'
          expect(feed[:students][0][:majors][1]).to eq 'Computer Science BA'
          expect(feed[:students][0][:terms_in_attendance]).to eq '2'
          expect(feed[:students][1][:majors][0]).to eq 'Break Science BA'
          expect(feed[:students][1][:terms_in_attendance]).to eq '6'
        end
      end

      context 'when no enrollments are present' do
        before { expect(User::BasicAttributes).to receive(:attributes_for_uids).exactly(0).times }
        let(:enrollments) { [] }
        it 'should report open enrollment spots that match the limit' do
          expect(feed[:sections][0][:enroll_limit]).to eq 650
          expect(feed[:sections][0][:enroll_count]).to eq 0
          expect(feed[:sections][0][:enroll_open]).to eq 650
          expect(feed[:sections][0][:waitlist_limit]).to eq 110
          expect(feed[:sections][0][:waitlist_count]).to eq 0
          expect(feed[:sections][0][:waitlist_open]).to eq 110
        end
      end

    end
  end


  context 'cross-listed courses', if: CampusOracle::Connection.test_data? do
    include_context 'instructor for crosslisted courses'
    let!(:crosslisted_course_id) do
      classes_for_instructor = MyClasses::Campus.new(instructor_id).fetch[:current]
      classes_for_instructor.first[:listings].first[:id]
    end

    it 'should merge sections for crosslisted courses' do
      feed = Rosters::Campus.new(instructor_id, course_id: crosslisted_course_id).get_feed
      expect(feed[:sections].length).to eq 6
    end
  end

end
