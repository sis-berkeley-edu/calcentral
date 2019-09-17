describe MyAcademics::Semesters do
  subject { described_class.new(uid) }
  let(:uid) { random_id }
  let(:campus_solutions_id) { random_id }
  let(:crosswalk) { double(lookup_campus_solutions_id: campus_solutions_id)}
  before do
    allow(CalnetCrosswalk::ByUid).to receive(:new).and_return(crosswalk)
  end

  let(:registration_status) {
    [
      {
        'student_id' => campus_solutions_id,
        'acadcareer_code' => 'UGRD',
        'term_id' => '2198',
        'withcncl_type_code' => nil,
        'withcncl_type_descr' => nil,
        'withcncl_reason_code' => nil,
        'withcncl_reason_descr' => nil,
        'withcncl_fromdate' => nil,
        'withcncl_lastattendate' => nil,
        'splstudyprog_type_code' => 'BGNNFILING',
        'splstudyprog_type_descr' => 'Filing Fee'
      }
    ]
  }

  describe '#initialize' do
    it 'initializes campus solutions id' do
      expect(subject.instance_eval { @campus_solutions_id }).to eq campus_solutions_id
    end
  end

  describe '#merge' do
    let(:data) { {} }
    let(:semester_feed) { [{}] }
    let(:populated_semester_feed) { [{}] }
    let(:data_with_semester_count) { {pastSemestersLimit: 3, pastSemestersCount: 5} }
    let(:result) { subject.merge(data) }
    let(:user_courses_all) { double(enrollments_summary: enrollments_summary, all_campus_courses: all_campus_courses) }
    let(:registration_status_data) { 'registration_status_data' }
    let(:enrollments_summary) { 'enrollments_summary' }
    let(:all_campus_courses) { 'all_campus_courses' }
    let(:academic_standings_data) do
      [
        {'term_id' => '2198', 'action_date' => DateTime.parse('2019-09-15')},
        {'term_id' => '2198', 'action_date' => DateTime.parse('2019-09-10')},
        {'term_id' => '2195', 'action_date' => DateTime.parse('2019-09-28')},
      ]
    end
    before do
      allow(EdoOracle::UserCourses::All).to receive(:new).with(user_id: uid).and_return(user_courses_all)
      allow(EdoOracle::Queries).to receive(:get_registration_status).with(uid).and_return(registration_status_data)
      allow(subject).to receive(:get_academic_standings).with(campus_solutions_id).and_return(academic_standings_data)
      allow(subject).to receive(:semester_feed).and_return(populated_semester_feed)
      allow(subject).to receive(:merge_semesters_count) do |data|
        data.merge({pastSemestersLimit: 3, pastSemestersCount: 5})
      end
    end
    context 'when feed is filtered for delegates' do
      let(:data) { {filteredForDelegate: true} }
      it 'sources enrollments from summary data' do
        expect(user_courses_all).to receive(:enrollments_summary).and_return(enrollments_summary)
        expect(user_courses_all).to_not receive(:all_campus_courses)
        expect(result).to be_an_instance_of Hash
      end
    end
    context 'when feed is not filtered for delegates' do
      let(:data) { {} }
      it 'sources enrollments from full courses data' do
        expect(user_courses_all).to receive(:all_campus_courses).and_return(all_campus_courses)
        expect(user_courses_all).to_not receive(:enrollments_summary)
        expect(result).to be_an_instance_of Hash
      end
    end
    context 'when nil elements returned from semesters feed' do
      let(:populated_semester_feed) { [{name: 'Fall 2019'}, nil] }
      it 'removes nil elements' do
        allow(subject).to receive(:semester_feed).and_return(populated_semester_feed)
        expect(result).to be_an_instance_of Hash
        expect(data[:semesters]).to eq([{name: 'Fall 2019'}])
      end
    end
    it 'passes expected data in semesters feed call' do
      expect(subject).to receive(:semester_feed).with(all_campus_courses).and_return(populated_semester_feed)
      expect(result).to be_an_instance_of Hash
    end
    it 'passes data to merge_semesters_count' do
      expect(subject).to receive(:merge_semesters_count).with({:semesters=>[{}]})
      expect(result).to be_an_instance_of Hash
    end
  end

  describe '#merge_semesters_count' do
    let(:data) { {} }
    let(:result) { subject.merge_semesters_count(data) }
    context 'when semesters present' do
      let(:data) do
        {
          semesters: [
            {timeBucket: 'past'},
            {timeBucket: 'past'},
            {timeBucket: 'past'},
            {timeBucket: 'past'},
            {timeBucket: 'past'},
            {timeBucket: 'current'},
            {timeBucket: 'future'},
          ]
        }
      end
      it 'merges past semesters limit into data' do
        expect(result[:pastSemestersLimit]).to eq 3
      end
      it 'merges past semesters count into data' do
        expect(result[:pastSemestersCount]).to eq 5
      end
    end
    context 'when semesters not present' do
      let(:data) { {not_semesters: []} }
      it 'returns data' do
        expect(result.has_key?(:semesters)).to eq false
        expect(result[:not_semesters]).to eq([])
      end
    end
  end

  describe '#process_enrollments' do
    let(:enrollment_term) do
      [
        {
          academicCareer: 'GRAD',
          course_code: 'PUBPOL 205',
          name: 'Advanced Policy Analysis',
          url: '/academics/semester/spring-2019/class/pubpol-205-2019-B',
        },
        {
          academicCareer: 'LAW',
          course_code: 'LAW 207.5',
          name: 'Advanced Legal Writing',
          url: '/academics/semester/spring-2019/class/law-207_5-2019-B',
        },
      ]
    end
    let(:term_id) { '2198' }
    let(:result) { subject.process_enrollments(enrollment_term, term_id) }
    before do
      allow(subject).to receive(:filter_enrollments).with(enrollment_term).and_return(enrollment_term)
      allow(subject).to receive(:course_info) {|enrollment| enrollment[:title] = enrollment[:name]; enrollment }
      allow(subject).to receive(:process_unfiltered_enrollment) {|enrollment| enrollment[:processed] = true; }
    end
    it 'filters enrollments' do
      expect(subject).to receive(:filter_enrollments).with(enrollment_term).and_return(enrollment_term)
      expect(result.count).to eq 2
    end
    context 'when feed is filtered for delegates' do
      before { subject.instance_eval { @filtered = true } }
      it 'does not process the enrollment' do
        expect(subject).to_not receive(:process_unfiltered_enrollment)
        expect(result[0][:course_code]).to eq 'PUBPOL 205'
        expect(result[1][:course_code]).to eq 'LAW 207.5'
      end
      it 'deletes the url for the enrollments' do
        expect(result[0].has_key?(:url)).to eq false
        expect(result[1].has_key?(:url)).to eq false
      end
    end
    context 'when feed is not filtered for delegates' do
      before { subject.instance_eval { @filtered = false } }
      it 'processes the enrollment' do
        expect(subject).to receive(:process_unfiltered_enrollment) {|enrollment| enrollment[:processed] = true; }
        expect(result.first[:processed]).to eq true
      end
      it 'does not delete the url for the enrollment' do
        expect(result[0][:url]).to eq '/academics/semester/spring-2019/class/pubpol-205-2019-B'
        expect(result[1][:url]).to eq '/academics/semester/spring-2019/class/law-207_5-2019-B'
      end
    end
  end

  describe '#filter_enrollments' do
    let(:enrollment_term) do
      [
        {course_code: 'Class A', role: class_a_role},
        {course_code: 'Class B', role: class_b_role},
        {course_code: 'Class C', role: class_c_role},
        {course_code: 'Class D', role: class_d_role},
      ]
    end
    let(:class_a_role) { 'Student' }
    let(:class_b_role) { 'Student' }
    let(:class_c_role) { 'Student' }
    let(:class_d_role) { 'Student' }
    let(:result) { subject.filter_enrollments(enrollment_term) }
    before { allow(subject).to receive(:exclude_enrollment_for_law?).and_return(false) }
    context 'when non-student enrollments present' do
      let(:class_b_role) { 'Instructor' }
      let(:class_d_role) { 'Instructor' }
      it 'filters out non-student enrollments' do
        expect(result.count).to eq 2
        expect(result[0][:course_code]).to eq 'Class A'
        expect(result[1][:course_code]).to eq 'Class C'
      end
    end
    context 'when enrollments are excluded for law' do
      before do
        allow(subject).to receive(:exclude_enrollment_for_law?) {|enrollment| enrollment[:course_code] == 'Class C' }
      end
      it 'filters out law excluded enrollments' do
        expect(result.count).to eq 3
        expect(result[0][:course_code]).to eq 'Class A'
        expect(result[1][:course_code]).to eq 'Class B'
        expect(result[2][:course_code]).to eq 'Class D'
      end
    end
  end

  describe '#exclude_enrollment_for_law?' do
    let(:enrollment) { {academicCareer: enrollment_academic_career} }
    let(:enrollment_academic_career) { 'UGRD' }
    let(:is_law_student) { false }
    let(:current_academic_roles) { { 'lawJointDegree' => in_law_joint_degree_student_group } }
    let(:in_law_joint_degree_student_group) { false }
    let(:users_active_academic_careers) { ['GRAD','LAW'] }
    let(:result) { subject.exclude_enrollment_for_law?(enrollment) }
    before do
      allow(subject).to receive(:law_student?).and_return(is_law_student)
      allow(subject).to receive(:current_academic_roles).and_return(current_academic_roles)
      allow(subject).to receive(:academic_careers).and_return(users_active_academic_careers)
    end
    context 'when user is not a law student' do
      let(:is_law_student) { false }
      it 'returns false' do
        expect(result).to eq false
      end
    end
    shared_examples 'filters non-GRAD and non-LAW' do
      context 'when enrollment matches GRAD career' do
        let(:enrollment_academic_career) { 'GRAD' }
        it 'returns false' do
          expect(result).to eq false
        end
      end
      context 'when enrollment matches LAW career' do
        let(:enrollment_academic_career) { 'LAW' }
        it 'returns false' do
          expect(result).to eq false
        end
      end
      context 'when enrollment matches UGRD career' do
        let(:enrollment_academic_career) { 'UGRD' }
        it 'returns true' do
          expect(result).to eq true
        end
      end
      context 'when enrollment matches UCBX career' do
        let(:enrollment_academic_career) { 'UCBX' }
        it 'returns true' do
          expect(result).to eq true
        end
      end
    end
    context 'when user is in the law joint degree student group' do
      let(:in_law_joint_degree_student_group) { true }
      context 'when user is a law student' do
        let(:is_law_student) { true }
        it_should_behave_like 'filters non-GRAD and non-LAW'
      end
      context 'when user is not a law student' do
        let(:is_law_student) { false }
        it_should_behave_like 'filters non-GRAD and non-LAW'
      end
    end
    context 'when user is not in the law joint degree student group' do
      let(:in_law_joint_degree_student_group) { false }
      context 'when user is not a law student' do
        let(:is_law_student) { false }
        context 'when the enrollment does not match the users active academic careers' do
          let(:users_active_academic_careers) { ['GRAD','LAW'] }
          let(:enrollment_academic_career) { 'UCBX' }
          it 'returns true' do
            expect(result).to eq false
          end
        end
      end
      context 'when user is a law student' do
        let(:is_law_student) { true }
        context 'when the enrollment matches the users active academic careers' do
          let(:users_active_academic_careers) { ['GRAD','LAW'] }
          let(:enrollment_academic_career) { 'LAW' }
          it 'returns false' do
            expect(result).to eq false
          end
        end
        context 'when the enrollment does not match the users active academic careers' do
          let(:users_active_academic_careers) { ['GRAD','LAW'] }
          let(:enrollment_academic_career) { 'UCBX' }
          it 'returns true' do
            expect(result).to eq true
          end
        end
      end
    end
  end

  describe '#current_academic_roles' do
    let(:my_academic_roles_feed) do
      {
        current: {
          'fpf' => false,
          'ugrd' => true,
          'grad' => false,
        }
      }
    end
    let(:my_academic_roles) do
      instance_double("MyAcademics::MyAcademicRoles").tap do |mock|
        allow(mock).to receive(:get_feed).and_return(my_academic_roles_feed)
      end
    end
    before do
      allow(MyAcademics::MyAcademicRoles).to receive(:new).with(uid).and_return(my_academic_roles)
    end
    let(:result) { subject.current_academic_roles }
    it 'memoizes academic roles' do
      expect(my_academic_roles).to receive(:get_feed).once.and_return(my_academic_roles_feed)
      result1 = subject.current_academic_roles
      result2 = subject.current_academic_roles
      expect(result1['ugrd']).to eq true
      expect(result1['fpf']).to eq false
      expect(result2['ugrd']).to eq true
      expect(result2['fpf']).to eq false
    end
  end

  describe '#academic_standings' do
    let(:result) { subject.academic_standings }
    let(:standings_feature_flag) { true }
    let(:academic_standings) { [] }
    before do
      allow(Settings.features).to receive(:standings).and_return(standings_feature_flag)
      allow(EdoOracle::Queries).to receive(:get_academic_standings).with(campus_solutions_id).and_return(academic_standings)
    end
    context 'when feature flag is disabled' do
      let(:standings_feature_flag) { false }
      it 'returns empty array' do
        expect(result).to eq([])
      end
    end
    context 'when feature flag is enabled' do
      let(:standings_feature_flag) { true }
      context 'when query returns no standings' do
        let(:academic_standings) { [] }
        it 'returns empty array' do
          expect(result).to eq([])
        end
      end
      context 'when query returns standings' do
        let(:academic_standings) do
          [
            {'term_id' => '2198', 'action_date' => DateTime.parse('2019-09-15')},
            {'term_id' => '2195', 'action_date' => DateTime.parse('2019-09-28')},
            {'term_id' => '2198', 'action_date' => DateTime.parse('2019-09-10')},
          ]
        end
        it 'sorts standings in descending order by term and action date' do
          expect(result.count).to eq 3
          expect(result[0]['term_id']).to eq '2198'
          expect(result[1]['term_id']).to eq '2198'
          expect(result[2]['term_id']).to eq '2195'
          expect(result[0]['action_date']).to eq DateTime.parse('2019-09-15')
          expect(result[1]['action_date']).to eq DateTime.parse('2019-09-10')
          expect(result[2]['action_date']).to eq DateTime.parse('2019-09-28')
        end
        it 'memoizes academic standing data' do
          expect(EdoOracle::Queries).to receive(:get_academic_standings).with(campus_solutions_id).once.and_return(academic_standings)
          result1 = subject.academic_standings
          result2 = subject.academic_standings
          expect(result1[0]['term_id']).to eq '2198'
          expect(result1[1]['term_id']).to eq '2198'
          expect(result1[2]['term_id']).to eq '2195'
          expect(result2[0]['term_id']).to eq '2198'
          expect(result2[1]['term_id']).to eq '2198'
          expect(result2[2]['term_id']).to eq '2195'
        end
      end
    end
  end

  describe '#registration_status' do
    let(:registration_status) { [{'student_id' => campus_solutions_id}] }
    before { allow(EdoOracle::Queries).to receive(:get_registration_status).and_return(registration_status) }
    it 'returns registration status' do
      result = subject.registration_status
      expect(result.count).to eq 1
      expect(result[0]['student_id']).to eq campus_solutions_id
    end
    it 'memoizes registration status data' do
      expect(EdoOracle::Queries).to receive(:get_registration_status).with(campus_solutions_id).once.and_return(registration_status)
      result1 = subject.registration_status
      result2 = subject.registration_status
      expect(result1[0]['student_id']).to eq campus_solutions_id
      expect(result2[0]['student_id']).to eq campus_solutions_id
    end
  end

  describe '#academic_careers' do
    let(:result) { subject.academic_careers }
    let(:grad_program_status) { 'AC' }
    let(:law_program_status) { 'AC' }
    let(:career_rows) do
      [
        {'acad_career' => 'GRAD', 'program_status' => grad_program_status },
        {'acad_career' => 'LAW', 'program_status' => law_program_status },
      ]
    end
    let(:edo_oracle_career) { double(fetch: career_rows) }
    before { allow(EdoOracle::Career).to receive(:new).with(user_id: uid).and_return(edo_oracle_career) }
    it 'memoizes the careers data' do
      expect(EdoOracle::Career).to receive(:new).with(user_id: uid).once.and_return(edo_oracle_career)
      result1 = subject.academic_careers
      result2 = subject.academic_careers
      expect(result1.count).to eq 2
      expect(result2.count).to eq 2
      expect(result1).to eq(['GRAD','LAW'])
      expect(result2).to eq(['GRAD','LAW'])
    end
    context 'when active and inactive careers are present' do
      let(:grad_program_status) { 'AC' }
      let(:law_program_status) { 'DC' }
      it 'returns only the active careers' do
        expect(result).to eq(['GRAD'])
      end
    end
    context 'when only inactive careers are present' do
      let(:grad_program_status) { 'DC' }
      let(:law_program_status) { 'DC' }
      it 'returns all the careers' do
        expect(result).to eq(['GRAD','LAW'])
      end
    end
  end

  describe '#process_unfiltered_enrollment' do
    let(:term_id) { '2198' }
    let(:enrollment) do
      {
        role: 'Student',
        sections: class_sections,
        slug: 'econ-1',
        session_code: nil,
        academicCareer: 'UGRD',
        courseCareerCode: 'UGRD',
        title: 'Introduction to Economics',
        url: '/academics/semester/fall-2019/class/econ-1-2019-D',
        course_code: 'ECON 1',
        dept: 'ECON',
        dept_code: 'ECON',
        courseCatalog: '1',
        course_id: 'econ-1-2019-D',
      }
    end
    let(:class_sections) { [] }
    let(:reserved_capacity_feature_flag) { false }
    let(:reserved_capacity_link_feature_flag) { false }
    let(:hide_grade_points) { false }
    let(:is_law_class) { false }
    before do
      allow(subject).to receive(:add_section_grade_option) {|section| section.merge({gradeOption: 'Letter'}) }
      allow(subject).to receive(:hide_points?).and_return(hide_grade_points)
      allow(subject).to receive(:law_class?).and_return(is_law_class)
      allow(subject).to receive(:law_class_enrollment).and_return({})
      allow(Settings.features).to receive(:reserved_capacity).and_return(reserved_capacity_feature_flag)
      allow(Settings.features).to receive(:reserved_capacity_link).and_return(reserved_capacity_link_feature_flag)
    end
    context 'when sections are present for enrollment' do
      let(:class_sections) do
        [
          {
            is_primary_section: true,
            grading: {
              gradePoints: BigDecimal.new('1.0')
            }
          },
          {
            is_primary_section: section_two_is_primary_section,
            waitlisted: section_two_is_waitlisted,
            grading: {
              gradePoints: BigDecimal.new('0.0')
            }
          },
        ]
      end
      let(:section_two_is_waitlisted) { false }
      let(:section_two_is_primary_section) { false }
      context 'when section is waitlisted' do
        let(:section_two_is_waitlisted) { true }
        context 'when reserved capacity feature flag is disabled' do
          let(:reserved_capacity_feature_flag) { false }
          it 'does not attempt to map reserved seats for section' do
            expect(subject).to_not receive(:map_reserved_seats)
            subject.process_unfiltered_enrollment(enrollment, term_id)
          end
        end
        context 'when reserved capacity feature flag is enabled' do
          let(:reserved_capacity_feature_flag) { true }
          it 'does not map reserved seats for the non-waitlisted section' do
            expect(subject).to receive(:map_reserved_seats) { |term_id, section| section[:capacity] = {unreservedSeats: 5, reservedSeats: []} }
            subject.process_unfiltered_enrollment(enrollment, term_id)
            expect(enrollment[:sections][0].has_key?(:capacity)).to eq false
          end
          it 'maps reserved seats for the waitlisted section' do
            expect(subject).to receive(:map_reserved_seats) { |term_id, section| section[:capacity] = {unreservedSeats: 5, reservedSeats: []} }
            subject.process_unfiltered_enrollment(enrollment, term_id)
            expect(enrollment[:sections][1][:capacity][:unreservedSeats]).to eq 5
          end
        end
      end
      context 'when reserved capacity link feature flag is disabled' do
        let(:reserved_capacity_link_feature_flag) { false }
        it 'does not add reserved seating rules link' do
          expect(subject).to_not receive(:add_reserved_seating_rules_link)
          subject.process_unfiltered_enrollment(enrollment, term_id)
          expect(enrollment[:sections][0].has_key?(:hasReservedSeats)).to eq false
          expect(enrollment[:sections][0].has_key?(:reservedSeatsInfoLink)).to eq false
          expect(enrollment[:sections][1].has_key?(:hasReservedSeats)).to eq false
          expect(enrollment[:sections][1].has_key?(:reservedSeatsInfoLink)).to eq false
        end
      end
      context 'when reserved capacity link feature flag is enabled' do
        let(:reserved_capacity_link_feature_flag) { true }
        it 'adds reserved seating rules link' do
          expect(subject).to receive(:add_reserved_seating_rules_link) do |term_id, course, section|
            section.merge!({hasReservedSeats: true, reservedSeatsInfoLink: 'http://example.com/'})
          end.twice
          subject.process_unfiltered_enrollment(enrollment, term_id)
          expect(enrollment[:sections][0][:hasReservedSeats]).to eq true
          expect(enrollment[:sections][0][:reservedSeatsInfoLink]).to eq 'http://example.com/'
          expect(enrollment[:sections][1][:hasReservedSeats]).to eq true
          expect(enrollment[:sections][1][:reservedSeatsInfoLink]).to eq 'http://example.com/'
        end
      end
      context 'when grade points should be hidden for course' do
        let(:hide_grade_points) { true }
        it 'returns nil for section grade points' do
          subject.process_unfiltered_enrollment(enrollment, term_id)
          expect(enrollment[:sections][0][:grading][:gradePoints]).to eq nil
          expect(enrollment[:sections][1][:grading][:gradePoints]).to eq nil
        end
      end
      context 'when grade points should not be hidden for course ' do
        let(:hide_grade_points) { false }
        it 'returns section grade points' do
          subject.process_unfiltered_enrollment(enrollment, term_id)
          expect(enrollment[:sections][0][:grading][:gradePoints]).to eq 1.0
          expect(enrollment[:sections][1][:grading][:gradePoints]).to eq 0.0
        end
      end
      context 'when processing a law course' do
        let(:is_law_class) { true }
        it 'tags the section as a law section' do
          subject.process_unfiltered_enrollment(enrollment, term_id)
          expect(enrollment[:sections][0][:isLaw]).to eq true
        end
      end
      context 'when processing a non-law course' do
        let(:is_law_class) { false }
        it 'tag the section as a non-law section' do
          subject.process_unfiltered_enrollment(enrollment, term_id)
          expect(enrollment[:sections][0][:isLaw]).to eq false
        end
      end
      context 'when multiple primary sections present' do
        let(:section_two_is_primary_section) { true }
        it 'makes call to merge multiple primaries' do
          expect(subject).to receive(:merge_multiple_primaries).once.and_return(nil)
          subject.process_unfiltered_enrollment(enrollment, term_id)
        end
      end
      it 'merges law enrollment data with section' do
        allow(subject).to receive(:law_class_enrollment).and_return({lawUnits: 5})
        subject.process_unfiltered_enrollment(enrollment, term_id)
        expect(enrollment[:sections][0][:lawUnits]).to eq 5
      end
    end
  end

  describe '#add_section_grade_option' do
    let(:result) { subject.add_section_grade_option(section) }
    context 'when section originates from campus solutions' do
      let(:section) { {grading_basis: 'GRD'} }
      it 'sets grade option description based on grading basis' do
        expect(Berkeley::GradeOptions).to receive(:grade_option_from_basis).with('GRD').and_return('Letter')
        subject.add_section_grade_option(section)
        expect(section[:gradeOption]).to eq 'Letter'
      end
    end
    context 'when section originates from legacy oracle' do
      let(:section) { {cred_cd: 'PF', pnp_flag: 'Y'} }
      it 'sets grade option description based on pnp flag and credit code' do
        expect(Berkeley::GradeOptions).to receive(:grade_option_for_enrollment).with('PF', 'Y').and_return('P/NP')
        subject.add_section_grade_option(section)
        expect(section[:gradeOption]).to eq 'P/NP'
      end
    end
  end

  describe '#add_reserved_seating_rules_link' do
    let(:term_id) { '2198' }
    let(:course) { {dept_code: 'ECON', courseCatalog: '1'} }
    let(:section) do
      {
        waitlisted: section_waitlisted,
        is_primary_section: section_is_primary_section,
        section_number: '001',
        instruction_format: 'LEC',
      }
    end
    let(:section_reserved_capacity_result) { [{'reserved_seating_rules_count' => reserved_seating_rules_count}] }
    let(:reserved_seating_rules_count) { BigDecimal.new('5.0') }
    let(:reserved_seats_info_link) { 'https://classes.berkeley.edu/content/2019-fall-econ-1-001-lec-001' }
    let(:fall_2019_term) { double(year: 2019, name: 'Fall 2019') }
    before do
      allow(Berkeley::Terms).to receive(:find_by_campus_solutions_id).with(term_id).and_return(fall_2019_term)
      allow(EdoOracle::Queries).to receive(:section_reserved_capacity_count).and_return(section_reserved_capacity_result)
      allow(LinkFetcher).to receive(:fetch_link).and_return(reserved_seats_info_link)
      subject.add_reserved_seating_rules_link(term_id, course, section)
    end
    context 'when section is not waitlisted' do
      let(:section_waitlisted) { false }
      let(:section_is_primary_section) { true }
      it 'does not add reserved seats info' do
        expect(section.has_key?(:hasReservedSeats)).to eq false
        expect(section.has_key?(:reservedSeatsInfoLink)).to eq false
      end
    end
    context 'when section is waitlisted' do
      let(:section_waitlisted) { true }
      context 'when section is not a primary section' do
        let(:section_is_primary_section) { false }
        it 'does not add reserved seats info' do
          expect(section.has_key?(:hasReservedSeats)).to eq false
          expect(section.has_key?(:reservedSeatsInfoLink)).to eq false
        end
      end
      context 'when section is a primary section' do
        let(:section_is_primary_section) { true }
        context 'when reserved capacity count is less than zero' do
          let(:reserved_seating_rules_count) { BigDecimal.new('-3.0') }
          it 'does not add reserved seats info' do
            expect(section.has_key?(:hasReservedSeats)).to eq false
            expect(section.has_key?(:reservedSeatsInfoLink)).to eq false
          end
        end
        context 'when reserved capacity count is zero' do
          let(:reserved_seating_rules_count) { BigDecimal.new('0.0') }
          it 'does not add reserved seats info' do
            expect(section.has_key?(:hasReservedSeats)).to eq false
            expect(section.has_key?(:reservedSeatsInfoLink)).to eq false
          end
        end
        context 'when reserved capacity count is more than zero' do
          let(:reserved_seating_rules_count) { BigDecimal.new('3.0') }
          it 'indicates that the section has reserved seats' do
            expect(section[:hasReservedSeats]).to eq true
          end
          it 'includes the reserved seats info link' do
            expect(section[:reservedSeatsInfoLink]).to eq reserved_seats_info_link
          end
        end
      end
    end
  end

  describe '#map_reserved_seats' do
    let(:term_id) { '2198' }
    let(:section) { {ccn: '27604'} }
    let(:section_reserved_capacity) { [] }
    let(:section_capacity) { [] }
    before do
      allow(EdoOracle::Queries).to receive(:get_section_reserved_capacity).with(term_id, section[:ccn]).and_return(section_reserved_capacity)
      allow(EdoOracle::Queries).to receive(:get_section_capacity).with(term_id, section[:ccn]).and_return(section_capacity)
    end
    context 'when no section reserved capacity available' do
      let(:section_reserved_capacity) { [] }
      it 'does not add reserved capacity data' do
        subject.map_reserved_seats(term_id, section)
        expect(section.has_key?(:capacity)).to eq false
      end
      it 'does not add hasReservedSeats boolean' do
        subject.map_reserved_seats(term_id, section)
        expect(section[:hasReservedSeats]).to eq nil
      end
    end
    context 'when section reserved capacity available' do
      let(:section_reserved_capacity) do
        [
          {
            'class_nbr' => BigDecimal.new('27604.0'),
            'class_section' => '001',
            'component' => 'LEC',
            'catalog_nbr' => '61A',
            'reserved_seats' => BigDecimal.new('10.0'),
            'reserved_seats_taken' =>BigDecimal.new('5.0'),
            'requirement_group_descr' => 'EECS/(MSE or NE), or Eng Undec',
            'term_id' => '2198'
          },
          {
            'class_nbr' => BigDecimal.new('27604.0'),
            'class_section' => '001',
            'component' => 'LEC',
            'catalog_nbr' => '61A',
            'reserved_seats' => BigDecimal.new('35.0'),
            'reserved_seats_taken' =>BigDecimal.new('34.0'),
            'requirement_group_descr' => 'BioE or BioE/MSE or Engin Und',
            'term_id' => '2198'
          },
        ]
      end
      context 'when section capacity figures unavailable' do
        let(:section_capacity) { [] }
        it 'adds hasReservedSeats boolean' do
          subject.map_reserved_seats(term_id, section)
          expect(section[:hasReservedSeats]).to eq true
        end
        it 'returns section with unreserved seat count unavailable' do
          subject.map_reserved_seats(term_id, section)
          expect(section[:capacity][:unreservedSeats]).to eq 'N/A'
        end
        it 'returns section with reserve counts' do
          subject.map_reserved_seats(term_id, section)
          expect(section[:capacity][:reservedSeats][0][:seats]).to eq '5'
          expect(section[:capacity][:reservedSeats][0][:seatsFor]).to eq 'EECS/(MSE or NE), or Eng Undec'
          expect(section[:capacity][:reservedSeats][1][:seats]).to eq '1'
          expect(section[:capacity][:reservedSeats][1][:seatsFor]).to eq 'BioE or BioE/MSE or Engin Und'
        end
      end
      context 'when section capacity figures available' do
        let(:section_capacity) do
          [
            {
              'enrolled_count' => BigDecimal.new('1955.0'),
              'waitlisted_count' => BigDecimal.new('2.0'),
              'min_enroll' => BigDecimal.new('0.0'),
              'max_enroll' => BigDecimal.new('2000.0'),
              'max_waitlist' => BigDecimal.new('300.0'),
            }
          ]
        end
        it 'adds hasReservedSeats boolean' do
          subject.map_reserved_seats(term_id, section)
          expect(section[:hasReservedSeats]).to eq true
        end
        it 'returns section with unreserved seat count' do
          subject.map_reserved_seats(term_id, section)
          expect(section[:capacity][:unreservedSeats]).to eq '39'
        end
        it 'returns section with reserve counts' do
          subject.map_reserved_seats(term_id, section)
          expect(section[:capacity][:reservedSeats][0][:seats]).to eq '5'
          expect(section[:capacity][:reservedSeats][0][:seatsFor]).to eq 'EECS/(MSE or NE), or Eng Undec'
          expect(section[:capacity][:reservedSeats][1][:seats]).to eq '1'
          expect(section[:capacity][:reservedSeats][1][:seatsFor]).to eq 'BioE or BioE/MSE or Engin Und'
        end
      end
    end
  end

  describe '#format_capacity' do
    let(:result) { subject.format_capacity(capacity_number) }
    context 'when capacity number is a negative integer' do
      let(:capacity_number) { -5 }
      it 'returns N/A' do
        expect(result).to eq 'N/A'
      end
    end
    context 'when capacity number is zero' do
      let(:capacity_number) { 0 }
      it 'returns number string' do
        expect(result).to eq '0'
      end
    end
    context 'when capacity number is a positive integer' do
      let(:capacity_number) { 23 }
      it 'returns number string' do
        expect(result).to eq '23'
      end
    end
  end

  describe '#law_class_enrollment' do
    let(:course) { {academicCareer: 'UGRD', term_id: '2192', requirementsDesignationCode: 'LPR'} }
    let(:section) { {ccn: '12345'} }
    let(:is_law_class) { true }
    let(:is_law_student) { true }
    let(:law_enrollment) { {'units_taken_law' => 5, 'rqmnt_desg_descr' => 'requirements designation description'}}
    let(:result) { subject.law_class_enrollment(course, section) }
    before do
      allow(EdoOracle::Queries).to receive(:get_law_enrollment).and_return(law_enrollment)
      allow(subject).to receive(:law_class?).and_return(is_law_class)
      allow(subject).to receive(:law_student?).and_return(is_law_student)
    end
    context 'when course is not a law class' do
      let(:is_law_class) { false }
      context 'when user is a law student' do
        let(:is_law_student) { true }
        it 'returns law units count' do
          expect(EdoOracle::Queries).to receive(:get_law_enrollment).and_return(law_enrollment)
          expect(result[:lawUnits]).to eq 5
        end
        it 'returns requirements designation description' do
          expect(EdoOracle::Queries).to receive(:get_law_enrollment).and_return(law_enrollment)
          expect(result[:requirementsDesignation]).to eq 'requirements designation description'
        end
      end
      context 'when user is not a law student' do
        let(:is_law_student) { false }
        it 'returns nil law units count' do
          expect(result[:lawUnits]).to eq nil
        end
        it 'returns nil requirements designation description' do
          expect(result[:requirementsDesignation]).to eq nil
        end
      end
    end
    context 'when course is a law class' do
      let(:is_law_class) { false }
      it 'returns law units count' do
        expect(EdoOracle::Queries).to receive(:get_law_enrollment).and_return(law_enrollment)
        expect(result[:lawUnits]).to eq 5
      end
      it 'returns requirements designation description' do
        expect(EdoOracle::Queries).to receive(:get_law_enrollment).and_return(law_enrollment)
        expect(result[:requirementsDesignation]).to eq 'requirements designation description'
      end
    end
  end

  describe '#merge_grades' do
    let(:semester) do
      {
        name: 'Fall 2019',
        termId: '2198',
        termCode: 'D',
        termYear: '2019',
        timeBucket: time_bucket,
        classes: semester_classes,
      }
    end
    let(:semester_classes) { [] }
    context 'when semester is not a current semester' do
      let(:time_bucket) { 'past' }
      it 'does not attempt to add midpoint grades' do
        expect(subject).to_not receive(:add_midpoint_grade)
        subject.merge_grades(semester)
      end
    end
    context 'when semester is a current semester' do
      let(:time_bucket) { 'current' }
      context 'when classes not present' do
        let(:semester_classes) { [] }
        it 'does not attempt to add midpoint grades' do
          expect(subject).to_not receive(:add_midpoint_grade)
          subject.merge_grades(semester)
        end
      end
      context 'when classes present' do
        let(:semester_classes) { [{role: class_role}] }
        context 'when class role is not student' do
          let(:class_role) { 'NotStudent' }
          it 'does not attempt to add midpoint grades' do
            expect(subject).to_not receive(:add_midpoint_grade)
            subject.merge_grades(semester)
          end
        end
        context 'when class role is student' do
          let(:class_role) { 'Student' }
          it 'attempts to add midpoint grades' do
            expect(subject).to receive(:add_midpoint_grade).with(semester_classes[0]).and_return(nil)
            subject.merge_grades(semester)
          end
        end
      end
    end
  end

  describe '#add_midpoint_grade' do
    let(:course) do
      {
        sections: [
          {ccn: '12345', is_primary_section: true, grading: {}},
          {ccn: '12346', is_primary_section: false, grading: {}},
        ]
      }
    end
    let(:hub_term_enrollments) do
      {
        feed: [
          {
            'classSection' => {
              'id' => hub_enrollment_class_section_id,
            },
            'grades' => hub_enrollment_primary_section_grades,
          }
        ]
      }
    end
    let(:final_grade) { {'type' => {'code' => 'FIN'}, 'mark' => 'A'} }
    let(:midpoint_grade) { {'type' => {'code' => 'MID'}, 'mark' => 'B'} }
    before { allow(subject).to receive(:hub_current_enrollments).and_return(hub_term_enrollments) }
    context 'when no midpoint grades present in primary class section' do
      let(:hub_enrollment_class_section_id) { '12345' }
      let(:hub_enrollment_primary_section_grades) { [] }
      it 'does not merge midpoint grade into section'  do
        subject.add_midpoint_grade(course)
        primary_section = course[:sections].find {|sec| sec[:is_primary_section] }
        expect(primary_section[:grading].has_key?(:midpointGrade)).to eq false
      end
    end
    context 'when no matching midpoint grades present' do
      let(:hub_enrollment_class_section_id) { '12347' }
      let(:hub_enrollment_primary_section_grades) { [final_grade, midpoint_grade] }
      it 'does not merge midpoint grade into section'  do
        subject.add_midpoint_grade(course)
        primary_section = course[:sections].find {|sec| sec[:is_primary_section] }
        expect(primary_section[:grading].has_key?(:midpointGrade)).to eq false
      end
    end
    context 'when matching midpoint grade is present' do
      let(:hub_enrollment_class_section_id) { '12345' }
      let(:hub_enrollment_primary_section_grades) { [final_grade, midpoint_grade] }
      it 'merges midpoint grade into section'  do
        subject.add_midpoint_grade(course)
        primary_section = course[:sections].find {|sec| sec[:is_primary_section] }
        expect(primary_section[:grading].has_key?(:midpointGrade)).to eq true
        expect(primary_section[:grading][:midpointGrade]).to eq 'B'
      end
    end
  end

  describe '#hub_current_enrollments' do
    let(:result) { subject.hub_current_enrollments }
    let(:current_term) { double(campus_solutions_id: '2198') }
    let(:hub_term_enrollments_response) do
      {
        statusCode: hub_term_enrollments_response_status_code,
        feed: hub_term_enrollments_response_feed,
        studentNotFound: hub_term_enrollments_response_student_not_found,
      }
    end
    let(:my_term_enrollments) { double(get_feed: hub_term_enrollments_response) }
    before { allow(subject).to receive(:current_term).and_return(current_term) }
    context 'when current term not present' do
      let(:current_term) { nil }
      it 'returns empty hash' do
        expect(result).to eq({})
      end
    end
    context 'when current term is present' do
      let(:current_term) { double(campus_solutions_id: '2198') }
      before { allow(HubEnrollments::MyTermEnrollments).to receive(:new).with(user_id: uid, term_id: '2198').and_return(my_term_enrollments) }
      context 'when student not found' do
        let(:hub_term_enrollments_response_status_code) { 404 }
        let(:hub_term_enrollments_response_feed) { [] }
        let(:hub_term_enrollments_response_student_not_found) { true }
        it 'memoizes api response' do
          expect(HubEnrollments::MyTermEnrollments).to receive(:new).with(user_id: uid, term_id: '2198').once.and_return(my_term_enrollments)
          result1 = subject.hub_current_enrollments
          result2 = subject.hub_current_enrollments
          expect(result1[:statusCode]).to eq 404
          expect(result2[:statusCode]).to eq 404
          expect(result1[:studentNotFound]).to eq true
          expect(result2[:studentNotFound]).to eq true
        end
      end
      context 'when student is found' do
        let(:hub_term_enrollments_response_status_code) { 200 }
        let(:hub_term_enrollments_response_student_not_found) { nil }
        let(:hub_term_enrollments_response_feed) do
          [
            {
              'enrollmentStatus' => {},
              'enrolledUnits' => {},
              'gradingBasis' => {},
              'classSection' => {}
            }
          ]
        end
        it 'memoizes api response' do
          expect(HubEnrollments::MyTermEnrollments).to receive(:new).with(user_id: uid, term_id: '2198').once.and_return(my_term_enrollments)
          result1 = subject.hub_current_enrollments
          result2 = subject.hub_current_enrollments
          expect(result1[:statusCode]).to eq 200
          expect(result2[:statusCode]).to eq 200
          expect(result1[:feed].count).to eq 1
          expect(result2[:feed].count).to eq 1
          expect(result1[:studentNotFound]).to eq nil
          expect(result2[:studentNotFound]).to eq nil
        end
      end
    end
  end

  describe '#hide_points?' do
    let(:result) { subject.hide_points? course  }
    let(:uid) { 300216 }
    let(:course) { {academicCareer: class_career} }

    context 'when class is for Law' do
      let(:class_career) { 'LAW' }
      it 'returns true' do
        expect(result).to be true
      end
    end
    context 'when student is in a concurrent (GRAD+LAW) program' do
      before do
        allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return '95727964'
      end
      context 'and class is for Undergrad' do
        let(:class_career) { 'UGRD' }
        it 'returns false' do
          expect(result).to be false
        end
      end
      context 'and class is for Grad' do
        let(:class_career) { 'GRAD' }
        it 'returns true' do
          expect(result).to be true
        end
      end
      context 'and class is for Law' do
        let(:class_career) { 'LAW' }
        it 'returns true' do
          expect(result).to be true
        end
      end
    end
  end

  describe '#law_student?' do
    let(:is_law_student) { true }
    let(:academic_roles_data) { {current: {'law' => is_law_student}} }
    let(:my_academic_roles) { double(get_feed: academic_roles_data) }
    let(:result) { subject.law_student? }
    it 'memoizes the law student boolean' do
      expect(MyAcademics::MyAcademicRoles).to receive(:new).with(uid).once.and_return(my_academic_roles)
      result1 = subject.law_student?
      result2 = subject.law_student?
      expect(result1).to eq true
      expect(result2).to eq true
    end
    context 'when student does not have law academic role' do
      let(:is_law_student) { false }
      it 'returns false' do
        expect(result).to eq false
      end
    end
  end

  describe '#law_class?' do
    let(:course) { {academicCareer: career_code} }
    let(:result) { subject.law_class?(course) }
    context 'when career code is \'LAW\'' do
      let(:career_code) { 'LAW' }
      it 'returns true' do
        expect(result).to eq true
      end
    end
    context 'when career code is not \'LAW\'' do
      let(:career_code) { 'GRAD' }
      it 'returns false' do
        expect(result).to eq false
      end
    end
  end

  describe '#grad_class?' do
    let(:course) { {academicCareer: career_code} }
    let(:result) { subject.grad_class?(course) }
    context 'when career code is \'GRAD\'' do
      let(:career_code) { 'GRAD' }
      it 'returns true' do
        expect(result).to eq true
      end
    end
    context 'when career code is not \'GRAD\'' do
      let(:career_code) { 'UGRD' }
      it 'returns false' do
        expect(result).to eq false
      end
    end
  end

  describe '#is_concurrent_student' do
    let(:edo_oracle_student) { double(concurrent?: true) }
    it 'memoizes the student concurrent boolean' do
      expect(EdoOracle::Student).to receive(:new).with(user_id: uid).once.and_return(edo_oracle_student)
      result1 = subject.is_concurrent_student
      result2 = subject.is_concurrent_student
      expect(result1).to eq true
      expect(result2).to eq true
    end
  end
end
