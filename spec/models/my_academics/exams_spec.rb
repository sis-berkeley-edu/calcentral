describe MyAcademics::Exams do
  let(:uid) { random_id }
  let(:student_feature_flag) { true }
  let(:instructor_feature_flag) { true }

  subject do
    MyAcademics::Exams.new uid
  end

  describe "#merge" do
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

  describe "#parse_semesters" do
    let(:student_semesters) do
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
      subject.parse_semesters(student_semesters)
    end
    it 'excludes processing of summer semesters' do
      expect(student_semesters[1][:name]).to eq 'Summer 2016'
      expect(student_semesters[1][:examSchedule]).to_not be
    end
    it 'excludes processing of past semesters' do
      expect(student_semesters[3][:name]).to eq 'Fall 2015'
      expect(student_semesters[3][:examSchedule]).to_not be
    end
    it 'processes current and future non-summer semesters' do
      expect(student_semesters[2][:name]).to eq 'Spring 2016'
      expect(student_semesters[2][:examSchedule]).to be
      expect(student_semesters[2][:examSchedule][0][:name]).to eq 'COMPSCI 1A'
      expect(student_semesters[0][:name]).to eq 'Fall 2016'
      expect(student_semesters[0][:examSchedule]).to be
      expect(student_semesters[0][:examSchedule][0][:name]).to eq 'COMPSCI 1A'
    end
  end

  describe "#get_semester_exam_schedule" do
    let(:student_semester) { {name: 'Spring 2017'} }
    let(:semester_exam_schedule) { subject.get_semester_exam_schedule(student_semester) }
    it 'obtains and processes semester exams in proper order' do
      expect(subject).to receive(:collect_semester_exams).with(student_semester).ordered
      expect(subject).to receive(:merge_course_timeslot_locations).ordered.and_return([])
      expect(subject).to receive(:flag_duplicate_semester_exam_courses).ordered
      expect(subject).to receive(:flag_conflicting_timeslots).ordered
      expect(semester_exam_schedule).to eq []
    end
  end

  describe "#collect_semester_exams" do
    let(:dummy_final_exams) do
      [
        {:exam_location=>"Wheeler 150"},
        {:exam_location=>"Valley Life Sciences 2040"}
      ]
    end
    let(:student_semester) do
      {
        name: 'Fall 2017',
        termId: '2178',
        termCode: 'D',
        timeBucket: 'current',
        slug: 'fall-2017',
        classes: fall_2017_classes
      }
    end
    let(:fall_2017_classes) do
      [
        non_student_class,
        undergrad_class
      ]
    end
    let(:non_student_class) do
      {
        role: 'Instructor',
        course_code: 'MCELLBI 104',
        academicCareer: 'UGRD',
        courseCatalog: '104',
        sections: []
      }
    end
    let(:undergrad_class) do
      {
        role: 'Student',
        course_code: 'BIOLOGY 1AL',
        academicCareer: 'UGRD',
        courseCatalog: '1AL',
        sections: [
          bio_1al_section_1,
          bio_1al_section_2
        ]
      }
    end
    let(:bio_1al_section_1) do
      {
        ccn: '13182',
        is_primary_section: true,
        section_label: "LEC 001"
      }
    end
    let(:bio_1al_section_2) do
      {
        ccn: '13138',
        is_primary_section: false,
        section_label: "LAB 323"
      }
    end
    let(:semester_exams) { subject.collect_semester_exams(student_semester) }
    it 'excludes processing of non-student classes' do
      expect(subject).to receive(:get_section_final_exams).with('2178','13182').and_return(dummy_final_exams)
      expect(semester_exams.count).to eq 2
      semester_exams.each do |exam|
        expect(exam[:name]).to_not eq 'MCELLBI 104'
      end
    end
    it 'excludes processing of non-primary sections' do
      expect(subject).to receive(:get_section_final_exams).with('2178','13182').and_return(dummy_final_exams)
      expect(semester_exams.count).to eq 2
      semester_exams.each do |exam|
        expect(exam[:section_label]).to_not eq 'LAB 323'
      end
    end
    it 'merges course and section data with parsed final exams' do
      allow(subject).to receive(:get_section_final_exams).with('2178','13182').and_return(dummy_final_exams)
      expect(semester_exams[0][:exam_location]).to eq 'Wheeler 150'
      expect(semester_exams[1][:exam_location]).to eq 'Valley Life Sciences 2040'
      semester_exams.each do |exam|
        expect(exam[:name]).to eq 'BIOLOGY 1AL'
        expect(exam[:academic_career]).to eq 'UGRD'
        expect(exam[:section_label]).to eq 'LEC 001'
        expect(exam[:waitlisted]).to eq nil
      end
    end
  end

  describe "#merge_course_timeslot_locations" do
    let(:semester_exams) do
      [
        {name: 'MCELLBI 102', :exam_slot=>Time.parse('2016-12-10 07:00:00'), :exam_location=>'Dwinelle 105'},
        {name: 'MCELLBI 101', :exam_slot=>Time.parse('2016-12-10 12:00:00'), :exam_location=>'Dwinelle 105'},
        {name: 'MCELLBI 104', :exam_slot=>Time.parse('2016-12-11 14:00:00'), :exam_location=>'Dwinelle 105'},
        {name: 'MCELLBI 104', :exam_slot=>Time.parse('2016-12-11 14:00:00'), :exam_location=>'Dwinelle 117'},
        {name: 'MCELLBI 136', :exam_slot=>Time.parse('2016-12-11 19:00:00'), :exam_location=>'Dwinelle 105'},
        {name: 'MCELLBI 136', :exam_slot=>Time.parse('2016-12-15 19:00:00'), :exam_location=>'Dwinelle 105'},
        {name: 'MCELLBI 136', :exam_slot=>Time.parse('2016-12-15 19:00:00'), :exam_location=>'Stanley 106'},
        {name: 'BIOLOGY 1AL', :exam_slot=>Time.parse('2016-12-15 19:00:00'), :exam_location=>'Dwinelle 105'},
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
  end

  describe "#flag_conflicting_timeslots" do
    let(:semester_exams) do
      [
        {name: 'MCELLBI 136', :section_label=>'LEC 001', :exam_slot=>Time.parse('2016-12-15 19:00:00')},
        {name: 'BIOLOGY 1AL', :section_label=>'LEC 001', :exam_slot=>Time.parse('2016-12-15 19:00:00')},
        {name: 'MCELLBI 136', :section_label=>'LEC 001', :exam_slot=>Time.parse('2016-12-15 19:00:00')},
        {name: 'MCELLBI 136', :section_label=>'LEC 001', :exam_slot=>Time.parse('2016-12-11 19:00:00')},
        {name: 'MCELLBI 104', :section_label=>'LEC 001', :exam_slot=>Time.parse('2016-12-11 14:00:00')},
        {name: 'MCELLBI 104', :section_label=>'LEC 002', :exam_slot=>Time.parse('2016-12-11 14:00:00')},
        {name: 'MCELLBI 101', :section_label=>'LEC 001', :exam_slot=>Time.parse('2016-12-10 12:00:00')},
        {name: 'MCELLBI 102', :section_label=>'LEC 001', :exam_slot=>Time.parse('2016-12-10 07:00:00')},
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
  end

  describe "#flag_duplicate_semester_exam_courses" do
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

  describe "#get_section_final_exams" do
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
    it 'returns parsed entries' do
      expect(exams.count).to eq 1
      expect(exams[0][:exam_location]).to eq 'Exam Location TBD'
      expect(exams[0][:exam_date]).to eq 'Thu Dec 15'
      expect(exams[0][:exam_time]).to eq '7:00P - 10:00P'
      expect(exams[0][:exam_slot]).to eq Time.parse('2016-12-15 19:00:00')
      expect(exams[0][:exception]).to eq 'N'
      expect(exams[0][:finalized]).to eq 'N'
    end
  end

  describe "#parse_exam" do
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
          expect(parsed_exam[:exam_date]).to eq 'Mon Dec 12'
          expect(parsed_exam[:exam_time]).to eq '1:00P - 3:30P'
          expect(parsed_exam[:exam_slot]).to eq Time.parse('2016-12-12 13:00:00')
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
        expect(parsed_exam[:exam_date]).to eq 'Mon Dec 12'
        expect(parsed_exam[:exam_time]).to eq '1:00P - 3:30P'
        expect(parsed_exam[:exam_slot]).to eq Time.parse('2016-12-12 13:00:00')
        expect(parsed_exam[:exception]).to eq 'N'
        expect(parsed_exam[:finalized]).to eq 'Y'
      end
    end
  end

  describe "#parse_cs_exam_date" do
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
    let(:exam_date_result) { subject.parse_cs_exam_date(exam) }

    context 'when exam data is pre-finalized' do
      let(:finalized) { 'N' }

      context 'when exam is not an exception' do
        let(:exam_exception) { 'N' }

        context 'when translate value is Y' do
          let(:exam_translate_value) { 'Y' }
          it 'returns date string' do
            expect(exam_date_result).to eq 'Mon Dec 5'
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
          expect(exam_date_result).to eq 'Mon Dec 5'
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

  describe "#parse_cs_exam_time" do
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

  describe "#single_letter_meridian_indicator" do
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

  describe "#parse_cs_exam_slot" do
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

  describe "#choose_cs_exam_location" do
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
            expect(exam_location).to eq 'Exam information not available at this time.'
          end
        end
      end

      context 'when exam is an exception' do
        let(:exam_exception) { 'Y' }
        it 'returns message indicating no exam information at this time' do
          expect(exam_location).to eq 'Exam information not available at this time.'
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
