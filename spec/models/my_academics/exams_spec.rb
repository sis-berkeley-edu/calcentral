describe MyAcademics::Exams do
  let(:uid) { random_id }
  let(:student_feature_flag) { true }
  let(:instructor_feature_flag) { true }

  subject do
    MyAcademics::Exams.new uid
  end

  describe '#merge' do
    let(:student_semesters) do
      [
        {name: 'Fall 2016', timeBucket: 'future'},
        {name: 'Spring 2016', timeBucket: 'current'}
      ]
    end
    let(:teaching_semesters) do
      [
        {name: 'Spring 2015', timeBucket: 'past'}
      ]
    end
    let(:feed) do
      {
        semesters: student_semesters,
        teachingSemesters: teaching_semesters
      }
    end
    before do
      allow(Settings.terms).to receive(:fake_now).and_return '2016-04-01'
      allow(Settings.features).to receive(:final_exam_schedule_student).and_return student_feature_flag
      allow(Settings.features).to receive(:final_exam_schedule_instructor).and_return instructor_feature_flag
      allow(subject).to receive(:parse_semesters) { |data| data }
    end

    context 'when student feature flag is on' do
      let(:student_feature_flag) { true }
      context 'when student semesters data present' do
        let(:feed) { {semesters: student_semesters} }
        it 'parses student semeseters feed' do
          expect(subject).to receive(:parse_semesters).with(student_semesters)
          subject.merge(feed)
        end
      end
      context 'when student semesters data is not present' do
        let(:feed) { {} }
        it 'parses student semeseters feed' do
          expect(subject).to_not receive(:parse_semesters).with(student_semesters)
          subject.merge(feed)
        end
      end
    end
    context 'when student feature flag is not on' do
      let(:student_feature_flag) { false }
      it 'does not parse feeds' do
        expect(subject).to_not receive(:parse_semesters).with(student_semesters)
        subject.merge(feed)
      end
    end

    context 'when instructor feature flag is on' do
      let(:instructor_feature_flag) { true }
      context 'when teaching semesters data present' do
        let(:feed) { {teachingSemesters: teaching_semesters} }
        it 'parses teaching feed' do
          expect(subject).to receive(:parse_semesters).with(teaching_semesters)
          subject.merge(feed)
        end
      end
      context 'when teaching semesters data is not present' do
        let(:feed) { {} }
        it 'parses teaching feed' do
          expect(subject).to_not receive(:parse_semesters).with(teaching_semesters)
          subject.merge(feed)
        end
      end
    end
    context 'when instructor feature flag is not on' do
      let(:instructor_feature_flag) { false }
      it 'does not parse feeds' do
        expect(subject).to_not receive(:parse_semesters).with(teaching_semesters)
        subject.merge(feed)
      end
    end
  end

  describe '#exam_message' do
    before { allow(CampusSolutions::MessageCatalog).to receive(:get_message_catalog_definition).with('32500', '110').and_return(message_object) }
    let(:message_object) do
      {
        messageSetNbr: '32500',
        messageNbr: '110',
        messageText: 'Final Exam Schedule Message',
        msgSeverity: 'M',
        descrlong: 'Final exams are based on the day and time a course is offered.'
      }
    end
    let(:message_response) { subject.exam_message }
    context 'when message present' do
      it 'returns long message description' do
        expect(message_response).to eq 'Final exams are based on the day and time a course is offered.'
      end
    end
    context 'when message not present' do
      let(:message_object) { nil }
      it 'returns nil' do
        expect(message_response).to eq nil
      end
    end
  end

  describe '#parse_semesters' do
    let(:semesters) do
      [
        fall_2016_semester_future,
        summer_2016_semester_future,
        spring_2016_semester_current,
        fall_2015_semester_past
      ]
    end
    let(:fall_2016_semester_future) do
      {
        name: 'Fall 2016',
        termCode: 'D',
        timeBucket: 'future'
      }
    end
    let(:summer_2016_semester_future) do
      {
        name: 'Summer 2016',
        termCode: 'C',
        timeBucket: 'future'
      }
    end
    let(:spring_2016_semester_current) do
      {
        name: 'Spring 2016',
        termCode: 'B',
        timeBucket: 'current'
      }
    end
    let(:fall_2015_semester_past) do
      {
        name: 'Fall 2015',
        termCode: 'D',
        timeBucket: 'past'
      }
    end
    before do
      allow(subject).to receive(:get_semester_exam_schedule).and_return([{ name: 'COMPSCI 1A' }])
      allow(subject).to receive(:collect_semester_course_career_codes).and_return(['UGRD','LAW'])
      subject.parse_semesters(semesters)
    end
    it 'excludes processing of summer semesters' do
      expect(semesters[1][:name]).to eq 'Summer 2016'
      expect(semesters[1][:exams]).to_not be
    end
    it 'excludes processing of past semesters' do
      expect(semesters[3][:name]).to eq 'Fall 2015'
      expect(semesters[3][:exams]).to_not be
    end
    it 'processes current and future non-summer semesters' do
      expect(semesters[2][:name]).to eq 'Spring 2016'
      expect(semesters[2][:exams]).to be
      expect(semesters[2][:exams][:schedule][0][:name]).to eq 'COMPSCI 1A'
      expect(semesters[0][:name]).to eq 'Fall 2016'
      expect(semesters[0][:exams]).to be
      expect(semesters[0][:exams][:schedule][0][:name]).to eq 'COMPSCI 1A'
    end
    it 'includes course career codes' do
      expect(semesters[0][:exams][:courseCareerCodes]).to eq ['UGRD','LAW']
    end
  end

  describe '#get_semester_exam_schedule' do
    let(:semester) { {name: 'Spring 2017'} }
    let(:semester_exam_schedule) { subject.get_semester_exam_schedule(semester) }
    it 'obtains and processes semester exams in proper order' do
      expect(subject).to receive(:collect_semester_exams).with(semester).ordered
      expect(subject).to receive(:merge_course_timeslot_locations).ordered
      expect(subject).to receive(:flag_duplicate_semester_exam_courses).ordered
      expect(subject).to receive(:flag_conflicting_timeslots).ordered
      expect(subject).to receive(:sort_semester_exams).ordered.and_return([])
      expect(semester_exam_schedule).to eq []
    end
  end

  describe '#sort_semester_exams' do
    let(:semester_exams) do
      [
        {name: 'CHEM 3BL' },
        {name: 'ANTHRO 4AC' },
        {name: 'CHEM 3B', exam_slot: Time.parse('2016-12-12 15:00:00')},
        {name: 'ANTHRO 3AC' },
        {name: 'MCELLBI 194', exam_slot: Time.now},
      ]
    end
    it 'sorts exams by slot, then alphabetically by name, with nil sorted last' do
      result = subject.sort_semester_exams(semester_exams)
      expect(result[0][:name]).to eq 'CHEM 3B'
      expect(result[1][:name]).to eq 'MCELLBI 194'
      expect(result[2][:name]).to eq 'ANTHRO 3AC'
      expect(result[3][:name]).to eq 'ANTHRO 4AC'
      expect(result[4][:name]).to eq 'CHEM 3BL'
    end
  end

  describe '#collect_semester_exams' do
    let(:semester) do
      {
        name: 'Fall 2017',
        termId: '2178',
        classes: fall_2017_classes
      }
    end
    let(:fall_2017_classes) { [fall_2017_class_1] }
    let(:fall_2017_class_1) do
      {
        role: 'Student',
        course_code: 'BIOLOGY 1AL',
        courseCareerCode: 'UGRD',
        courseCatalog: '1AL',
        sections: [bio_1al_section_1, bio_1al_section_2],
        listings: bio_1al_listings
      }
    end
    let(:dummy_final_exams) do
      [
        { exam_location: 'Wheeler 150' },
        { exam_location: 'Valley Life Sciences 2040' }
      ]
    end
    let(:bio_1al_section_1) { {ccn: '13182', is_primary_section: true, section_label: 'LEC 001', waitlisted: false} }
    let(:bio_1al_section_2) { {ccn: '13138', is_primary_section: false, section_label: 'LAB 323', waitlisted: false} }
    let(:bio_1al_listings) do
      [
        {:course_code=>"BIOLOGY 1AL", :dept=>"BIOLOGY", :dept_code=>"BIOLOGY", :courseCatalog=>"1AL", :course_id=>"biology-1al-2017-D"},
        {:course_code=>"PSYCH 1AL", :dept=>"PSYCH", :dept_code=>"BIOLOGY", :courseCatalog=>"1AL", :course_id=>"psych-1al-2017-D"}
      ]
    end
    let(:semester_exams) { subject.collect_semester_exams(semester) }
    before do
      expect(subject).to receive(:get_section_final_exams).and_return(dummy_final_exams)
      allow(subject).to receive(:post_merge_process_section_final_exams) do |merged_final_exams|
        merged_final_exams
      end
    end
    it 'mutates semester feed, adding exams to sections' do
      expect(semester_exams.count).to eq 2
      final_exams = fall_2017_class_1[:sections][0][:finalExams]
      expect(final_exams.count).to eq 2
      expect(final_exams[0][:exam_location]).to eq 'Wheeler 150'
      expect(final_exams[1][:exam_location]).to eq 'Valley Life Sciences 2040'
    end
    it 'includes course and section properties' do
      expect(semester_exams.count).to eq 2
      semester_exams.each do |exam|
        expect(exam).to have_keys([:name, :courseRole, :courseCareerCode, :section_label, :waitlisted])
      end
    end
    it 'excludes processing of non-primary sections' do
      expect(semester_exams.count).to eq 2
      semester_exams.each do |exam|
        expect(exam[:section_label]).to_not eq 'LAB 323'
      end
    end
    context 'when multiple courses apply to user' do
      let(:fall_2017_class_2) do
        {
          role: 'Student',
          course_code: 'BIOLOGY 202',
          courseCareerCode: fall_2017_class_2_career_code,
          courseCatalog: '202',
          listings: [
            {:course_code=>"BIOLOGY 202", :dept=>"BIOLOGY", :dept_code=>"BIOLOGY", :courseCatalog=>"202", :course_id=>"biology-202-2017-D"},
          ],
          sections: [bio_202_section_1]
        }
      end
      let(:bio_202_section_1) { {ccn: '13139', is_primary_section: true, section_label: 'LEC 001'} }
      let(:fall_2017_classes) { [fall_2017_class_1, fall_2017_class_2] }
      let(:fall_2017_class_2_career_code) { 'UGRD' }
      context 'user is associated with a graduate course' do
        let(:fall_2017_class_2_career_code) { 'GRAD' }
        it 'excludes graduate course' do
          expect(semester_exams.count).to eq 2
          expect(semester_exams[0][:name]).to eq 'BIOLOGY 1AL'
          expect(semester_exams[0][:section_label]).to eq 'LEC 001'
          expect(semester_exams[0][:exam_location]).to eq 'Wheeler 150'
          expect(semester_exams[1][:name]).to eq 'BIOLOGY 1AL'
          expect(semester_exams[1][:section_label]).to eq 'LEC 001'
          expect(semester_exams[1][:exam_location]).to eq 'Valley Life Sciences 2040'
          expect(semester_exams[2]).to_not be
        end
      end
      context 'user is associated with a law course' do
        let(:fall_2017_class_2_career_code) { 'LAW' }
        it 'excludes law course' do
          expect(semester_exams.count).to eq 2
          expect(semester_exams[0][:name]).to eq 'BIOLOGY 1AL'
          expect(semester_exams[0][:section_label]).to eq 'LEC 001'
          expect(semester_exams[0][:exam_location]).to eq 'Wheeler 150'
          expect(semester_exams[1][:name]).to eq 'BIOLOGY 1AL'
          expect(semester_exams[1][:section_label]).to eq 'LEC 001'
          expect(semester_exams[1][:exam_location]).to eq 'Valley Life Sciences 2040'
          expect(semester_exams[2]).to_not be
        end
      end
    end
    context 'when course has no final exam schedules' do
      let(:dummy_final_exams) { [] }
      it 'course is still included' do
        expect(semester_exams.count).to eq 1
        expect(semester_exams[0][:name]).to eq 'BIOLOGY 1AL'
        expect(semester_exams[0][:section_label]).to eq 'LEC 001'
      end
      it 'exam location reflects no exam information at this time' do
        expect(semester_exams.count).to eq 1
        expect(semester_exams[0][:exam_location]).to eq 'Exam Information not available at this time.'
      end
    end
    it 'merges course and section data with parsed final exams' do
      expect(semester_exams[0][:exam_location]).to eq 'Wheeler 150'
      expect(semester_exams[1][:exam_location]).to eq 'Valley Life Sciences 2040'
      semester_exams.each do |exam|
        expect(exam[:name]).to eq 'BIOLOGY 1AL'
        expect(exam[:courseRole]).to eq 'Student'
        expect(exam[:courseCareerCode]).to eq 'UGRD'
        expect(exam[:crossListedCourseNames]).to eq ['BIOLOGY 1AL','PSYCH 1AL']
        expect(exam[:section_label]).to eq 'LEC 001'
        expect(exam[:waitlisted]).to eq false
      end
    end
  end

  describe '#filter_section_payload' do
    let(:section_payload) do
      [
        {
          courseCareerCode: 'UGRD',
          courseRole: 'Instructor',
          crossListedCourseNames: ['MCELLBI C61', 'PSYCH C61'],
          exam_date: 'Wed May 9',
          exam_date_instructor: 'Wed, May 9',
          exam_location: 'RSF Fieldhouse',
          exam_slot: '2018-05-09T18:30:00.000Z',
          exam_time: '11:30A - 2:30P',
          exam_type: 'Y',
          exception: 'N',
          finalized: 'Y',
          name: 'MCELLBI C61',
          section_label: 'LEC 001',
          waitlisted: nil,
        }
      ]
    end
    it 'returns only section specific exam schedule information' do
      result = subject.filter_section_payload(section_payload)
      expect(result[0]).to_not have_keys([
        :courseRole,
        :courseCareerCode,
        :crossListedCourseNames,
        :display_section_label,
        :exam_type,
        :exception,
        :finalized,
        :name,
        :time_conflict,
        :waitlisted,
      ])
      expect(result[0]).to have_keys([:exam_date, :exam_time, :exam_location])
    end
  end

  describe '#post_merge_process_section_final_exams' do
    let(:finalized) { 'N' }
    let(:exam_type) { 'Y' }
    let(:course_role) { 'Student' }
    let(:exam_location) { 'Exam Location TBD' }
    let(:merged_section_final_exam) do
      {
        courseRole: course_role,
        exam_type: exam_type,
        exam_location: exam_location,
        finalized: finalized,
      }
    end
    let(:merged_section_final_exams) { [merged_section_final_exam] }
    let(:processed_final_exams) { subject.post_merge_process_section_final_exams(merged_section_final_exams) }
    context 'when final exam data present for section' do
      let(:finalized) { 'N' }
      it 'returns section final exams as provided' do
        expect(processed_final_exams[0][:exam_location]).to eq 'Exam Location TBD'
      end
    end
    context 'when final exam data not present for section' do
      let(:finalized) { nil }
      context 'when course role is student' do
        let(:course_role) { 'Student' }
        it 'returns exam with indication of no final exam information available' do
          expect(processed_final_exams[0][:exam_location]).to eq 'Exam Information not available at this time.'
        end
      end
      context 'when course role is instructor with exam type \'N\'' do
        let(:course_role) { 'Instructor' }
        it 'returns exam with indication of no final exam information available' do
          expect(processed_final_exams[0][:exam_location]).to eq 'Exam Information not available at this time.'
        end
        context 'when exam type is type \'N\'' do
          let(:exam_type) { 'N' }
          it 'returns exam with indication of no final exam for course' do
            expect(processed_final_exams[0][:exam_location]).to eq 'No final exam for this course'
          end
        end
      end
    end
  end

  describe '#collect_semester_course_career_codes' do
    let(:semester) { {classes: fall_2017_classes} }
    let(:fall_2017_classes) { [fall_2017_class_1, fall_2017_class_2, fall_2017_class_3] }
    let(:fall_2017_class_1) do
      {
        courseCareerCode: 'UGRD',
        sections: [
          { is_primary_section: true },
          { is_primary_section: false }
        ]
      }
    end
    let(:fall_2017_class_2) do
      {
        courseCareerCode: 'LAW',
        sections: [
          { is_primary_section: false },
          { is_primary_section: false }
        ]
      }
    end
    let(:fall_2017_class_3) do
      {
        courseCareerCode: 'GRAD',
        sections: [
          { is_primary_section: false },
          { is_primary_section: true }
        ]
      }
    end
    let(:semester_course_career_codes) { subject.collect_semester_course_career_codes(semester) }
    it 'returns array of course career codes for courses with primary sections' do
      expect(semester_course_career_codes).to eq ['UGRD','GRAD']
    end
  end

  describe '#merge_course_timeslot_locations' do
    let(:semester_exams) do
      [
        {name: 'MCELLBI 102', exam_slot: Time.parse('2016-12-10 07:00:00'), exam_location: 'Dwinelle 105'},
        {name: 'MCELLBI 101', exam_slot: Time.parse('2016-12-10 12:00:00'), exam_location: 'Dwinelle 105'},
        {name: 'MCELLBI 104', exam_slot: Time.parse('2016-12-11 14:00:00'), exam_location: 'Dwinelle 105'},
        {name: 'MCELLBI 104', exam_slot: Time.parse('2016-12-11 14:00:00'), exam_location: 'Dwinelle 117'},
        {name: 'MCELLBI 136', exam_slot: Time.parse('2016-12-11 19:00:00'), exam_location: 'Dwinelle 105'},
        {name: 'MCELLBI 136', exam_slot: Time.parse('2016-12-15 19:00:00'), exam_location: 'Dwinelle 105'},
        {name: 'MCELLBI 136', exam_slot: Time.parse('2016-12-15 19:00:00'), exam_location: 'Stanley 106'},
        {name: 'BIOLOGY 1AL', exam_slot: Time.parse('2016-12-15 19:00:00'), exam_location: 'Dwinelle 105'},
      ]
    end
    let(:exams) { subject.merge_course_timeslot_locations(semester_exams) }
    it 'merges exams together for the same course + timeslot combination' do
      expect(exams.count).to eq 6
      expect(exams[0][:exam_locations].count).to eq 1
      expect(exams[1][:exam_locations].count).to eq 1
      expect(exams[2][:exam_locations].count).to eq 2
      expect(exams[3][:exam_locations].count).to eq 1
      expect(exams[4][:exam_locations].count).to eq 2
      expect(exams[5][:exam_locations].count).to eq 1
      expect(exams[0][:name]).to eq 'MCELLBI 102'
      expect(exams[1][:name]).to eq 'MCELLBI 101'
      expect(exams[2][:name]).to eq 'MCELLBI 104'
      expect(exams[3][:name]).to eq 'MCELLBI 136'
      expect(exams[4][:name]).to eq 'MCELLBI 136'
      expect(exams[5][:name]).to eq 'BIOLOGY 1AL'
      expect(exams[0][:exam_locations][0]).to eq 'Dwinelle 105'
      expect(exams[1][:exam_locations][0]).to eq 'Dwinelle 105'
      expect(exams[2][:exam_locations][0]).to eq 'Dwinelle 105'
      expect(exams[2][:exam_locations][1]).to eq 'Dwinelle 117'
      expect(exams[3][:exam_locations][0]).to eq 'Dwinelle 105'
      expect(exams[4][:exam_locations][0]).to eq 'Dwinelle 105'
      expect(exams[4][:exam_locations][1]).to eq 'Stanley 106'
      expect(exams[5][:exam_locations][0]).to eq 'Dwinelle 105'
    end
    context 'when semester exams without schedule data' do
      let(:semester_exams) do
        [
          {name: 'MCELLBI 101', courseCareerCode: 'UGRD', section_label: 'LEC 001'},
          {name: 'MCELLBI 101', courseCareerCode: 'UGRD', section_label: 'LEC 002'},
          {name: 'MCELLBI 102', exam_slot: Time.parse('2016-12-11 14:00:00'), exam_location: 'Dwinelle 105'}
        ]
      end
      it 'returns exam entries without schedule data' do
        expect(exams.count).to eq 3
        expect(exams[0][:exam_locations]).to eq []
        expect(exams[1][:exam_locations]).to eq []
        expect(exams[2][:exam_locations]).to eq ['Dwinelle 105']
        expect(exams[0][:exam_slot]).to eq nil
        expect(exams[1][:exam_slot]).to eq nil
        expect(exams[2][:exam_slot]).to eq Time.parse('2016-12-11 14:00:00')
      end
    end
  end

  describe '#flag_conflicting_timeslots' do
    let(:semester_exams) do
      [
        {name: 'MCELLBI 136', section_label: 'LEC 001', exam_slot: Time.parse('2016-12-15 19:00:00')},
        {name: 'BIOLOGY 1AL', section_label: 'LEC 001', exam_slot: Time.parse('2016-12-15 19:00:00')},
        {name: 'MCELLBI 136', section_label: 'LEC 001', exam_slot: Time.parse('2016-12-15 19:00:00')},
        {name: 'MCELLBI 136', section_label: 'LEC 001', exam_slot: Time.parse('2016-12-11 19:00:00')},
        {name: 'MCELLBI 104', section_label: 'LEC 001', exam_slot: Time.parse('2016-12-11 14:00:00')},
        {name: 'MCELLBI 104', section_label: 'LEC 002', exam_slot: Time.parse('2016-12-11 14:00:00')},
        {name: 'MCELLBI 101', section_label: 'LEC 001', exam_slot: Time.parse('2016-12-10 12:00:00')},
        {name: 'MCELLBI 102', section_label: 'LEC 001', exam_slot: Time.parse('2016-12-10 07:00:00')},
      ]
    end
    before { subject.flag_conflicting_timeslots(semester_exams) }
    it 'flags exams with conflicting timeslots' do
      expect(semester_exams.count).to eq 8
      expect(semester_exams[0][:time_conflict]).to eq true
      expect(semester_exams[1][:time_conflict]).to eq true
      expect(semester_exams[2][:time_conflict]).to eq true
      expect(semester_exams[4][:time_conflict]).to eq true
      expect(semester_exams[5][:time_conflict]).to eq true
    end
    it 'flags exams as not having conflicting timeslots' do
      expect(semester_exams[3][:time_conflict]).to eq false
      expect(semester_exams[6][:time_conflict]).to eq false
      expect(semester_exams[7][:time_conflict]).to eq false
    end
    context 'when exam slots are nil' do
      let(:semester_exams) do
        [
          {name: 'MCELLBI 104', section_label: 'LEC 002'},
          {name: 'MCELLBI 101', section_label: 'LEC 001'},
          {name: 'MCELLBI 102', section_label: 'LEC 001', exam_slot: Time.parse('2016-12-10 07:00:00')},
        ]
      end
      it 'does not flag nil slots as conflicting' do
        expect(semester_exams.count).to eq 3
        semester_exams.each {|exam| expect(exam[:time_conflict]).to eq false }
      end
    end
  end

  describe '#is_datetime?' do
    it 'returns false when not a date or time object' do
      expect(subject.is_datetime?(nil)).to eq false
      expect(subject.is_datetime?('hello')).to eq false
      expect(subject.is_datetime?(123)).to eq false
      expect(subject.is_datetime?({hello: 123})).to eq false
      expect(subject.is_datetime?([1,2,3])).to eq false
    end

    it 'returns true when is a date or time object' do
      expect(subject.is_datetime?(Date.parse('2018-01-01'))).to eq true
      expect(subject.is_datetime?(Time.parse('2018-01-01 14:33:01'))).to eq true
      expect(subject.is_datetime?(DateTime.parse('2018-01-01 14:33:01'))).to eq true
      expect(subject.is_datetime?(Time.zone.now)).to eq true
    end
  end

  describe '#flag_duplicate_semester_exam_courses' do
    let(:semester_exams) do
      [
        {name: 'MCELLBI 136'},
        {name: 'BIOLOGY 1AL'},
        {name: 'MCELLBI 136'},
        {name: 'MCELLBI 104'},
        {name: 'MCELLBI 136'},
      ]
    end
    before { subject.flag_duplicate_semester_exam_courses(semester_exams) }
    it 'flags exams when course name is used more than once' do
      expect(semester_exams[0][:display_section_label]).to eq true
      expect(semester_exams[1][:display_section_label]).to eq false
      expect(semester_exams[2][:display_section_label]).to eq true
      expect(semester_exams[3][:display_section_label]).to eq false
      expect(semester_exams[4][:display_section_label]).to eq true
    end
  end

  describe '#get_section_final_exams' do
    let(:valid_final_exam) do
      {
        'term_id' => '2168',
        'session_id' => '1',
        'section_id' => '13182',
        'exam_type' => 'Y',
        'exam_date' => Time.parse('2016-12-15 00:00:00 UTC'),
        'exam_start_time' => Time.parse('1900-01-01 19:00:00 UTC'),
        'exam_end_time' => Time.parse('1900-01-01 22:00:00 UTC'),
        'exam_exception' => 'N',
        'location' => 'Dwinelle 105',
        'finalized' => 'N'
      }
    end
    let(:last_class_meeting) do
      {
        'term_id' => '2168',
        'session_id' => '1',
        'section_id' => '13182',
        'exam_type' => 'L',
        'exam_date' => Time.parse('2016-12-15 00:00:00 UTC'),
        'exam_start_time' => Time.parse('1900-01-01 19:00:00 UTC'),
        'exam_end_time' => Time.parse('1900-01-01 22:00:00 UTC'),
        'exam_exception' => 'N',
        'location' => 'Dwinelle 117',
        'finalized' => 'N'
      }
    end
    let(:final_exams) { [valid_final_exam] }
    let(:exams) { subject.get_section_final_exams('2168', '13181') }
    before { allow(EdoOracle::Queries).to receive(:get_section_final_exams).and_return(final_exams) }
    context 'when final exam entries are duplicated' do
      let(:final_exams) { [valid_final_exam, valid_final_exam] }
      it 'returns unique entries' do
        expect(exams.count).to eq 1
      end
    end
    context 'when exams include non-finalized entries with type code \'L\'' do
      let(:final_exams) { [valid_final_exam, last_class_meeting] }
      it 'excludes non-finalized entries with type code \'L\'' do
        expect(exams.count).to eq 1
      end
    end
    context 'when no final exam schedules present' do
      let(:final_exams) { [] }
      it 'returns empty array' do
        expect(exams.count).to eq 0
      end
    end
    it 'returns parsed entries' do
      expect(exams.count).to eq 1
      expect(exams[0][:exam_location]).to eq 'Exam Location TBD'
      expect(exams[0][:exam_date]).to eq 'Thu, Dec 15'
      expect(exams[0][:exam_time]).to eq '7:00P - 10:00P'
      expect(exams[0][:exam_slot]).to eq Time.parse('2016-12-15 19:00:00')
      expect(exams[0][:exception]).to eq 'N'
      expect(exams[0][:finalized]).to eq 'N'
    end
  end

  describe '#parse_exam' do
    let(:exam) do
      {
        location: exam_location,
        exam_date: exam_date,
        exam_start_time: exam_start_time,
        exam_end_time: exam_end_time,
        exam_exception: exam_exception,
        finalized: exam_finalized,
        exam_type: exam_translate_value
      }
    end
    let(:exam_location) { 'Kroeber 221' }
    let(:exam_date) { Time.parse('2016-12-12 00:00:00 UTC') }
    let(:exam_start_time) { Time.parse('1900-01-01 13:00:00 UTC') }
    let(:exam_end_time) { Time.parse('1900-01-01 15:30:00 UTC') }
    let(:exam_exception) { 'N' }
    let(:exam_finalized) { 'N' }
    let(:exam_translate_value) { 'Y' }
    let(:parsed_exam) { subject.parse_exam(exam) }
    context 'when exam data is pre-finalized' do
      let(:exam_finalized) { 'N' }
      context 'when translate value is not L' do
        let(:exam_translate_value) { 'Y' }
        it 'returns exam object' do
          expect(parsed_exam[:exam_location]).to eq 'Exam Location TBD'
          expect(parsed_exam[:exam_date]).to eq 'Mon, Dec 12'
          expect(parsed_exam[:exam_date_instructor]).to eq 'Mon, Dec 12, 2016'
          expect(parsed_exam[:exam_time]).to eq '1:00P - 3:30P'
          expect(parsed_exam[:exam_slot]).to eq Time.parse('2016-12-12 13:00:00')
          expect(parsed_exam[:exam_type]).to eq exam_translate_value
          expect(parsed_exam[:exception]).to eq 'N'
          expect(parsed_exam[:finalized]).to eq 'N'
        end
      end
      context 'when translate value is L (Last Class Meeting)' do
        let(:exam_translate_value) { 'L' }
        it 'returns nil' do
          expect(parsed_exam).to eq nil
        end
      end
    end
    context 'when exam data is finalized' do
      let(:exam_finalized) { 'Y' }
      it 'returns exam object' do
        expect(parsed_exam[:exam_location]).to eq 'Kroeber 221'
        expect(parsed_exam[:exam_date]).to eq 'Mon, Dec 12'
        expect(parsed_exam[:exam_date_instructor]).to eq 'Mon, Dec 12, 2016'
        expect(parsed_exam[:exam_time]).to eq '1:00P - 3:30P'
        expect(parsed_exam[:exam_slot]).to eq Time.parse('2016-12-12 13:00:00')
        expect(parsed_exam[:exam_type]).to eq exam_translate_value
        expect(parsed_exam[:exception]).to eq 'N'
        expect(parsed_exam[:finalized]).to eq 'Y'
      end
    end
  end

  describe '#parse_cs_exam_date' do
    let(:exam) do
      {
        exam_date: exam_date,
        exam_exception: exam_exception,
        finalized: exam_finalized,
        exam_type: exam_translate_value
      }
    end
    let(:exam_date) { Time.parse('2016-12-05 00:00:00 UTC') }
    let(:exam_finalized) { 'N' }
    let(:exam_exception) { 'N' }
    let(:exam_translate_value) { 'Y' }
    let(:instructor_format) { false }
    let(:exam_date_result) { subject.parse_cs_exam_date(exam, instructor_format) }
    context 'when exam data is pre-finalized' do
      let(:finalized) { 'N' }

      context 'when exam is not an exception' do
        let(:exam_exception) { 'N' }

        context 'when translate value is Y' do
          let(:exam_translate_value) { 'Y' }
          it 'returns date string' do
            expect(exam_date_result).to eq 'Mon, Dec 5'
          end
          context 'when exam date is not present' do
            let(:exam_date) { nil }
            it 'returns nil' do
              expect(exam_date_result).to eq nil
            end
          end
          context 'when exam date is in the current year' do
            let(:exam_date) { Time.now }
            context 'when default format is requested' do
              let(:instructor_format) { false }
              it 'returns date with standard format' do
                expect(exam_date_result).to eq exam_date.strftime('%a, %b %-d')
              end
            end
            context 'when instructor format is requested' do
              let(:instructor_format) { true }
              it 'returns date with full year format' do
                expect(exam_date_result).to eq exam_date.strftime('%a, %b %-d')
              end
            end
          end
          context 'when exam date is not in the current year' do
            let(:exam_date) { Time.now + 1.year + 1.month }
            context 'when default format is requested' do
              let(:instructor_format) { false }
              it 'returns date with standard format' do
                expect(exam_date_result).to eq exam_date.strftime('%a, %b %-d')
              end
            end
            context 'when instructor format is requested' do
              let(:instructor_format) { true }
              it 'returns date with full year format' do
                expect(exam_date_result).to eq exam_date.strftime('%a, %b %-d, %Y')
              end
            end
          end
        end
        context 'when translate value is N' do
          let(:exam_translate_value) { 'N' }
          it 'returns nil' do
            expect(exam_date_result).to eq nil
          end
        end
        context 'when translate value is A' do
          let(:exam_translate_value) { 'A' }
          it 'returns nil' do
            expect(exam_date_result).to eq nil
          end
        end
      end
      context 'when exam is an exception' do
        let(:exam_exception) { 'Y' }
        it 'returns nil' do
          expect(exam_date_result).to eq nil
        end
      end
    end

    context 'when exam data is finalized' do
      let(:finalized) { 'Y' }
      context 'when exam date is present' do
        it 'returns date string' do
          expect(exam_date_result).to eq 'Mon, Dec 5'
        end
        context 'when exam date is not in the current year' do
          let(:exam_date) { Time.now + 1.year + 1.month }
          context 'when default format is requested' do
            let(:instructor_format) { false }
            it 'returns date with standard format' do
              expect(exam_date_result).to eq exam_date.strftime('%a, %b %-d')
            end
          end
          context 'when long format is requested' do
            let(:instructor_format) { true }
            it 'returns date with full year format' do
              expect(exam_date_result).to eq exam_date.strftime('%a, %b %-d, %Y')
            end
          end
        end
      end
      context 'when exam date is not present' do
        let(:exam_date) { nil }
        it 'returns nil' do
          expect(exam_date_result).to eq nil
        end
      end
    end
  end

  describe '#time_is_current_year?' do
    it 'returns true when within the current year' do
      expect(subject.time_is_current_year?(Time.now)).to eq true
      expect(subject.time_is_current_year?(Date.today.at_beginning_of_year.to_time)).to eq true
      expect(subject.time_is_current_year?(Date.today.at_end_of_year.to_time)).to eq true
    end
    it 'returns false when within a previous or future year' do
      expect(subject.time_is_current_year?(Time.now + 1.year)).to eq false
      expect(subject.time_is_current_year?(Time.now - 1.year)).to eq false
      expect(subject.time_is_current_year?(Time.now.at_beginning_of_year - 5.seconds)).to eq false
      expect(subject.time_is_current_year?(Time.now.at_end_of_year + 5.seconds)).to eq false
    end
  end

  describe '#parse_cs_exam_time' do
    let(:exam) do
      {
        exam_start_time: exam_start_time,
        exam_end_time: exam_end_time,
        exam_exception: exam_exception,
        finalized: exam_finalized,
        exam_type: exam_translate_value
      }
    end
    let(:exam_start_time) { Time.parse('1900-01-01 11:00:00 UTC') }
    let(:exam_end_time) { Time.parse('1900-01-01 13:30:00 UTC') }
    let(:exam_finalized) { 'N' }
    let(:exam_exception) { 'N' }
    let(:exam_translate_value) { 'Y' }
    let(:long_format) { false }
    let(:exam_time) { subject.parse_cs_exam_time(exam) }

    context 'when exam data is pre-finalized' do
      let(:finalized) { 'N' }

      context 'when exam is not an exception' do
        let(:exam_exception) { 'N' }
        context 'when translate value is Y' do
          let(:exam_translate_value) { 'Y' }
          it 'returns start and end time' do
            expect(exam_time).to eq '11:00A - 1:30P'
          end
        end
        context 'when translate value is C' do
          let(:exam_translate_value) { 'C' }
          it 'returns start and end time' do
            expect(exam_time).to eq '11:00A - 1:30P'
          end
        end
        context 'when translate value is N' do
          let(:exam_translate_value) { 'N' }
          it 'returns nil' do
            expect(exam_time).to eq nil
          end
        end
        context 'when translate value is A' do
          let(:exam_translate_value) { 'A' }
          it 'returns nil' do
            expect(exam_time).to eq nil
          end
        end
      end
      context 'when exam is an exception' do
        let(:exam_exception) { 'Y' }
        it 'returns nil' do
          expect(exam_time).to eq nil
        end
      end
    end

    context 'when exam data is finalized' do
      let(:finalized) { 'Y' }
      context 'when exam start and end time is present' do
        it 'returns start and end time' do
          expect(exam_time).to eq '11:00A - 1:30P'
        end
      end
      context 'when exam start time is not present' do
        let(:exam_start_time) { nil }
        it 'returns nil' do
          expect(exam_time).to eq nil
        end
      end
      context 'when exam end time is not present' do
        let(:exam_end_time) { nil }
        it 'returns nil' do
          expect(exam_time).to eq nil
        end
      end

    end
  end

  describe '#single_letter_meridian_indicator' do
    subject { MyAcademics::Exams.new(uid).single_letter_meridian_indicator(meridian_indicator) }
    context 'when indicator is \'pm\'' do
      let(:meridian_indicator) { 'pm' }
      it { should eq 'P' }
    end
    context 'when indicator is \'PM\'' do
      let(:meridian_indicator) { 'PM' }
      it { should eq 'P' }
    end
    context 'when indicator is \'am\'' do
      let(:meridian_indicator) { 'am' }
      it { should eq 'A' }
    end
    context 'when indicator is \'AM\'' do
      let(:meridian_indicator) { 'AM' }
      it { should eq 'A' }
    end
    context 'when indicator is unexpected' do
      let(:meridian_indicator) { 'EDM' }
      it { should eq '' }
    end
  end

  describe '#parse_cs_exam_slot' do
    let(:exam) do
      {
        exam_date: exam_date,
        exam_start_time: exam_start_time,
        exam_exception: exam_exception,
        finalized: exam_finalized,
        exam_type: exam_translate_value
      }
    end
    let(:exam_date) { Time.parse('2016-12-12 00:00:00 UTC') }
    let(:exam_start_time) { Time.parse('1900-01-01 19:00:00 UTC') }
    let(:exam_finalized) { 'N' }
    let(:exam_exception) { 'N' }
    let(:exam_translate_value) { 'Y' }
    let(:exam_slot) { subject.parse_cs_exam_slot(exam) }

    context 'when exam data is pre-finalized' do
      let(:finalized) { 'N' }
      context 'when exam is not an exception' do
        let(:exam_exception) { 'N' }

        context 'when translate value is N (No)' do
          let(:exam_translate_value) { 'N' }
          it 'returns none' do
            expect(exam_slot).to eq 'none'
          end
        end
        context 'when translate value is A (Alternate Method)' do
          let(:exam_translate_value) { 'A' }
          it 'returns none' do
            expect(exam_slot).to eq 'none'
          end
        end
        context 'when translate value is not N or A' do
          let(:exam_translate_value) { 'Y' }
          context 'when time and date not present' do
            let(:exam_start_time) { nil }
            let(:exam_date) { nil }
            it 'returns none' do
              expect(exam_slot).to eq 'none'
            end
          end
          context 'when only date present' do
            let(:exam_start_time) { nil }
            it 'returns formatted date' do
              expect(exam_slot).to eq Time.parse('2016-12-12 00:00:00')
            end
          end
          context 'when time and date present' do
            it 'returns formatted date and time' do
              expect(exam_slot).to eq Time.parse('2016-12-12 19:00:00')
            end
          end
        end
      end

      context 'when exam is an exception' do
        let(:exam_exception) { 'Y' }
        it 'returns none' do
          expect(exam_slot).to eq 'none'
        end
      end
    end

    context 'when exam data is finalized' do
      let(:finalized) { 'Y' }
      context 'when time and date not present' do
        let(:exam_start_time) { nil }
        let(:exam_date) { nil }
        it 'returns none' do
          expect(exam_slot).to eq 'none'
        end
      end
      context 'when only date present' do
        let(:exam_start_time) { nil }
        it 'returns formatted date' do
          expect(exam_slot).to eq Time.parse('2016-12-12 00:00:00')
        end
      end
      context 'when time and date present' do
        it 'returns formatted date and time' do
          expect(exam_slot).to eq Time.parse('2016-12-12 19:00:00')
        end
      end
    end
  end

  describe '#choose_cs_exam_location' do
    let(:exam) do
      {
        location: exam_location_value,
        exam_exception: exam_exception,
        finalized: exam_finalized,
        exam_type: exam_translate_value
      }
    end
    let(:exam_location_value) { 'Dwinelle 117' }
    let(:exam_finalized) { 'N' }
    let(:exam_exception) { 'N' }
    let(:exam_translate_value) { 'Y' }
    let(:exam_location) { subject.choose_cs_exam_location(exam) }

    context 'when exam data is pre-finalized' do
      let(:finalized) { 'N' }

      context 'when exam is not an exception' do
        let(:exam_exception) { 'N' }
        context 'when translate value is Y (Yes)' do
          let(:exam_translate_value) { 'Y' }
          it 'returns indication that location is to be determined' do
            expect(exam_location).to eq 'Exam Location TBD'
          end
        end
        context 'when translate value is C (Common Final)' do
          let(:exam_translate_value) { 'C' }
          it 'returns indication that location is to be determined' do
            expect(exam_location).to eq 'Exam Location TBD'
          end
        end
        context 'when translate value is not Y or C' do
          let(:exam_translate_value) { 'N' }
          it 'returns message indicating no exam information at this time' do
            expect(exam_location).to eq 'Exam Information not available at this time.'
          end
        end
      end

      context 'when exam is an exception' do
        let(:exam_exception) { 'Y' }
        it 'returns message indicating no exam information at this time' do
          expect(exam_location).to eq 'Exam Information not available at this time.'
        end
      end
    end

    context 'when exam data is finalized' do
      let(:exam_finalized) { 'Y' }
      context 'when exam location is present' do
        it 'returns exam location string' do
          expect(exam_location).to eq 'Dwinelle 117'
        end
      end
      context 'when exam location is not present' do
        let(:exam_location_value) { nil }
        it 'returns nil' do
          expect(exam_location).to eq nil
        end
      end
    end
  end

end
