describe MyAcademics::Semesters do

  describe '#find_academic_careers', testext: false do
    subject { described_class.new(uid).find_academic_careers }
    let(:uid) { 300216 }

    context 'with an active career' do
      it 'returns a list of active careers' do
        expect(subject).to contain_exactly('GRAD', 'LAW')
      end
    end
    context 'with no active career' do
      let(:uid) { 790833 }
      it 'returns a list of all careers' do
        expect(subject).to contain_exactly('UGRD', 'UCBX')
      end
    end
  end

  describe '#semester_feed', testext: false do
    subject { described_class.new(uid).semester_feed(enrollment_terms, reg_status_data, standing_data) }

    before do
      allow(Settings.edodb).to receive(:fake).and_return false
      allow(Settings.terms).to receive(:fake_now).and_return nil
      allow(Settings.terms).to receive(:use_term_definitions_json_file).and_return true
      allow(Settings.features).to receive(:hub_term_api).and_return false
    end

    let(:enrollment_terms) { EdoOracle::UserCourses::All.new(user_id: uid, fake: false).get_all_campus_courses }
    let(:reg_status_data) { [] }
    let(:standing_data) { [] }
    let(:uid) { 790833 }

    it 'sorts the terms in descending order' do
      expect(subject.count).to eq 2
      expect(subject[0][:termId]).to eq '2178'
      expect(subject[1][:termId]).to eq '2172'
    end
    it 'provides grading data' do
      expect(subject[0][:classes][0][:sections][0][:grading][:gradePoints]).to eq 0
      expect(subject[0][:classes][0][:sections][0][:grading][:gradingBasis]).to eq 'GRD'
      expect(subject[1][:classes][0][:sections][0][:grading][:gradePoints]).to eq 0
      expect(subject[1][:classes][0][:sections][0][:grading][:gradingBasis]).to eq 'GRD'
    end
    it 'flags class sections as non-Law based on the class academic career' do
      expect(subject[0][:classes][0][:sections][0][:isLaw]).to be_falsey
      expect(subject[1][:classes][0][:sections][0][:isLaw]).to be_falsey
    end
    context 'when all of student\'s grades have been received for the term' do
      it 'provides the total earned units' do
        expect(subject[0][:totalUnits]).to eq 3
        expect(subject[0][:totalLawUnits]).to be nil
        expect(subject[0][:isGradingComplete]).to eq true
      end
    end
    context 'when grades have not all been received for the term' do
      it 'provides the total enrolled units' do
        expect(subject[1][:totalUnits]).to eq 4
        expect(subject[1][:totalLawUnits]).to be nil
        expect(subject[1][:isGradingComplete]).to eq false
      end
    end
    context 'when student has a LAW career term' do
      let(:uid) { 490452 }
      context 'when grades have not all been received for the term' do
        it 'provides the total enrolled units and law units' do
          expect(subject.count).to eq 1
          expect(subject[0][:termId]).to eq '2185'
          expect(subject[0][:totalUnits]).to eq 0
          expect(subject[0][:totalLawUnits]).to eq 16
          expect(subject[0][:isGradingComplete]).to eq false
        end
        it 'provides the classes and sections the student was enrolled in' do
          expect(subject[0][:classes]).to be
          expect(subject[0][:classes].count).to eq 2

          expect(subject[0][:classes][0][:sections]).to be
          expect(subject[0][:classes][0][:sections].count).to eq 1
          expect(subject[0][:classes][0][:sections][0][:ccn]).to eq '12392'
          expect(subject[0][:classes][0][:sections][0][:units]).to eq 2
          expect(subject[0][:classes][0][:sections][0][:lawUnits]).to eq 3
          expect(subject[0][:classes][0][:sections][0][:requirementsDesignation]).to be nil

          expect(subject[0][:classes][1][:sections]).to be
          expect(subject[0][:classes][1][:sections].count).to eq 1
          expect(subject[0][:classes][1][:sections][0][:ccn]).to eq '11950'
          expect(subject[0][:classes][1][:sections][0][:units]).to eq 3
          expect(subject[0][:classes][1][:sections][0][:lawUnits]).to eq 3
          expect(subject[0][:classes][1][:sections][0][:requirementsDesignation]).to eq 'Fulfills Professional Responsibility Requirement'
        end
        it 'suppresses Grade Points on Law classes' do
          expect(subject[0][:classes][0][:sections][0][:grading][:gradePoints]).to be nil
          expect(subject[0][:classes][0][:sections][0][:grading][:gradingBasis]).to eq 'LAW'
          expect(subject[0][:classes][1][:sections][0][:grading][:gradePoints]).to be nil
          expect(subject[0][:classes][1][:sections][0][:grading][:gradingBasis]).to eq 'LAW'
        end
        it 'flags class sections as Law based on the class academic career' do
          expect(subject[0][:classes][0][:sections][0][:isLaw]).to be true
          expect(subject[0][:classes][1][:sections][0][:isLaw]).to be true
        end
      end
    end
    context 'when student is in a concurrent (GRAD+LAW) program' do
      before do
        allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return '95727964'
      end
      let(:uid) { 300216 }
      it 'suppresses Grade Points on both Grad and Law classes' do
        expect(subject[0][:classes][0][:academicCareer]).to eq 'GRAD'
        expect(subject[0][:classes][0][:sections][0][:grading][:gradePoints]).to be nil
        expect(subject[0][:classes][0][:sections][0][:grading][:gradingBasis]).to eq 'CNC'

        expect(subject[0][:classes][1][:academicCareer]).to eq 'LAW'
        expect(subject[0][:classes][1][:sections][0][:grading][:gradePoints]).to be nil
        expect(subject[0][:classes][1][:sections][0][:grading][:gradingBasis]).to eq 'GRD'

        expect(subject[0][:classes][2][:academicCareer]).to eq 'LAW'
        expect(subject[0][:classes][2][:sections][0][:grading][:gradePoints]).to be nil
        expect(subject[0][:classes][2][:sections][0][:grading][:gradingBasis]).to eq 'GRD'
      end
    end
  end

  describe '#hide_points?' do
    subject { described_class.new(uid).hide_points? course  }
    let(:uid) { 300216 }
    let(:course) do
      {
        academicCareer: class_career
      }
    end

    context 'when class is for Law' do
      let(:class_career) { 'LAW' }
      it 'returns true' do
        expect(subject).to be true
      end
    end
    context 'when student is in a concurrent (GRAD+LAW) program' do
      before do
        allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return '95727964'
      end
      context 'and class is for Undergrad' do
        let(:class_career) { 'UGRD' }
        it 'returns false' do
          expect(subject).to be false
        end
      end
      context 'and class is for Grad' do
        let(:class_career) { 'GRAD' }
        it 'returns true' do
          expect(subject).to be true
        end
      end
      context 'and class is for Law' do
        let(:class_career) { 'LAW' }
        it 'returns true' do
          expect(subject).to be true
        end
      end
    end
  end
  context 'using stubbed proxy' do
    let(:feed) { {}.tap { |feed| MyAcademics::Semesters.new(random_id).merge(feed) } }

    let(:term_keys) { ['2015-D', '2016-B', '2016-C', '2016-D'] }

    def generate_enrollment_data(opts={})
      Hash[term_keys.map{|key| [key, enrollment_term(key, opts)]}]
    end

    def enrollment_term(key, opts={})
      rand(2..4).times.map { course_enrollment(key, opts) }
    end

    def course_enrollment(term_key, opts={})
      term_yr, term_cd = term_key.split('-')
      dept = random_string(5)
      catid = rand(999).to_s
      enrollment = {
        id: "#{dept}-#{catid}-#{term_key}",
        slug: "#{dept}-#{catid}",
        course_code: "#{dept.upcase} #{catid}",
        term_yr: term_yr,
        term_cd: term_cd,
        term_id: 9999,
        session_code: [nil, 'A', 'B', 'C', 'D', 'E'].sample,
        dept: dept.upcase,
        catid: catid,
        course_catalog: catid,
        emitter: 'Campus',
        name: random_string(15).capitalize,
        sections: course_enrollment_sections(opts),
        role: 'Student'
      }
      enrollment
    end

    def course_enrollment_sections(opts)
      sections = [ course_enrollment_section(opts.merge(is_primary_section: true)) ]
      rand(1..3).times { sections << course_enrollment_section(opts.merge(is_primary_section: false)) }
      sections
    end

    def course_enrollment_section(opts={})
      format = opts[:format] || ['LEC', 'DIS', 'SEM'].sample
      section_number = opts[:section_number] || "00#{rand(9)}"
      is_primary_section = opts[:is_primary_section] || false
      waitlisted = opts[:waitlisted]
      section = {
        associated_primary_id: opts[:associated_primary_id],
        ccn: opts[:ccn] || random_ccn,
        instruction_format: format,
        is_primary_section: is_primary_section,
        section_label: "#{format} #{section_number}",
        section_number: section_number,
        units: (is_primary_section ? rand(1.0..5.0).round(1) : 0.0),
        grading: {
          grade: is_primary_section ? random_grade : nil,
          gradingBasis: 'GRD',
          gradePoints: rand(0.0..16.0)
        },
        schedules: {
          oneTime: [],
          recurring: [{
                        buildingName: random_string(10),
                        roomNumber: rand(9).to_s,
                        schedule: 'MWF 11:00A-12:00P'
                      }]
        },
        waitlisted: waitlisted,
        instructors: [{name: random_name, uid: random_id}]
      }
      section
    end

    shared_examples 'semester ordering' do
      it 'should include the expected semesters in reverse order' do
        expect(feed[:semesters].length).to eq 4
        term_keys.sort.reverse.each_with_index do |key, index|
          term_year, term_code = key.split('-')
          expect(feed[:semesters][index]).to include(
           {
             termCode: term_code,
             termYear: term_year,
             name: Berkeley::TermCodes.to_english(term_year, term_code)
           })
        end
      end

      it 'should place semesters in the right buckets' do
        current_term = Berkeley::Terms.fetch.current
        current_term_key = "#{current_term.year}-#{current_term.code}"
        feed[:semesters].each do |s|
          semester_key = "#{s[:termYear]}-#{s[:termCode]}"
          if semester_key < current_term_key
            expect(s[:timeBucket]).to eq 'past'
          elsif semester_key > current_term_key
            expect(s[:timeBucket]).to eq 'future'
          else
            expect(s[:timeBucket]).to eq 'current'
          end
        end
      end
    end

    shared_examples 'a good and proper munge' do
      include_examples 'semester ordering'
      it 'should preserve structure of enrollment data' do
        feed[:semesters].each do |s|
          expect(s[:hasEnrollmentData]).to eq true
          enrollment_semester = enrollment_data["#{s[:termYear]}-#{s[:termCode]}"]
          expect(s[:classes].length).to eq enrollment_semester.length
          s[:classes].each do |course|
            matching_enrollment = enrollment_semester.find { |e| e[:id] == course[:course_id] }
            expect(course[:sections].count).to eq matching_enrollment[:sections].count
            expect(course[:title]).to eq matching_enrollment[:name]
            expect(course[:courseCatalog]).to eq matching_enrollment[:course_catalog]
            expect(course[:url]).to include matching_enrollment[:slug]
            [:course_code, :dept, :dept_desc, :role, :slug, :session_code].each do |key|
              expect(course[key]).to eq matching_enrollment[key]
            end
          end
        end
      end

      it 'should not flag it as filtered for delegate' do
        feed[:semesters].each do |s|
          expect(s[:filteredForDelegate]).to eq false
        end
      end
    end

    context 'Campus Solutions academic data' do
      before do
        allow(Settings.terms).to receive(:fake_now).and_return '2016-04-01'
        allow(Settings.terms).to receive(:legacy_cutoff).and_return 'fall-2009'
        expect(CampusOracle::Queries).not_to receive :get_enrolled_sections
        allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
      end
      let(:enrollment_data) { generate_enrollment_data }
      it_should_behave_like 'a good and proper munge'
      it 'advertises Campus Solutions source' do
        expect(feed[:semesters]).to all include({campusSolutionsTerm: true})
      end
    end

    context 'Has withdrawal data' do
      before do
        allow(Settings.terms).to receive(:fake_now).and_return '2016-04-01'
        allow(Settings.terms).to receive(:legacy_cutoff).and_return 'fall-2009'
        expect(CampusOracle::Queries).not_to receive :get_enrolled_sections
        allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
        allow(EdoOracle::Queries).to receive(:get_registration_status).and_return withdrawal_data
      end
      let(:withdrawal_data) do
        [
          {
            'student_id'=>'25259127',
            'acadcareer_code'=>'UGRD',
            'term_id'=>'2158',
            'withcncl_type_code'=>'WDR',
            'withcncl_type_descr'=>'Withdrew',
            'withcncl_reason_code'=>'RETR',
            'withcncl_reason_descr'=>'Retroactive',
            'withcncl_fromdate'=> Time.parse('2016-02-04 00:00:00 UTC'),
            'withcncl_lastattendate'=> Time.parse('2014-12-12 00:00:00 UTC')
          }
        ]
      end
      let(:enrollment_data) { generate_enrollment_data }
      it 'should add withdrawal data' do
        expect([feed[:semesters][3]]).to all include({hasWithdrawalData: true})
      end
    end

    context 'Has standing data' do
      before do
        allow(Settings.terms).to receive(:fake_now).and_return '2016-04-01'
        allow(Settings.terms).to receive(:legacy_cutoff).and_return 'fall-2009'
        allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
        allow(EdoOracle::Queries).to receive(:get_academic_standings).and_return standing_data
      end
      let(:standing_data) {
        [
          {
            'acad_standing_status' => 'GST',
            'acad_standing_status_descr'=>  'Good Standing',
            'acad_standing_action_descr'=> 'Probation Ended',
            'term_id' => '2158',
            'action_date'=> DateTime.parse('07-AUG-14')
          }
        ]
      }
      let(:enrollment_data) { generate_enrollment_data }
      it 'should add standing data' do
        expect(feed[:semesters][3]).to include({hasStandingData: true})
        expect(feed[:semesters][3][:standing][:acadStandingStatus]).to eq 'GST'
      end
    end

    context 'Has Absentia data' do
      before do
        allow(Settings.terms).to receive(:fake_now).and_return '2016-04-01'
        allow(Settings.terms).to receive(:legacy_cutoff).and_return 'fall-2009'
        expect(CampusOracle::Queries).not_to receive :get_enrolled_sections
        allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
        allow(EdoOracle::Queries).to receive(:get_registration_status).and_return study_prog_data
      end
      let(:study_prog_data) do
        [
          {
            'student_id'=>'25259127',
            'acadcareer_code'=>'UGRD',
            'term_id'=>'2158',
            'splstudyprog_type_code'=>'OGPFABSENT',
            'splstudyprog_type_descr'=>'In Absentia'
          }
        ]
      end
      let(:enrollment_data) { generate_enrollment_data }
      it 'should add study program  data' do
        expect([feed[:semesters][3]]).to all include({hasStudyProgData: true})
      end
    end

    context 'Has Filing Fee data' do
      before do
        allow(Settings.terms).to receive(:fake_now).and_return '2016-04-01'
        allow(Settings.terms).to receive(:legacy_cutoff).and_return 'fall-2009'
        expect(CampusOracle::Queries).not_to receive :get_enrolled_sections
        allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
        allow(EdoOracle::Queries).to receive(:get_registration_status).and_return study_prog_data
      end
      let(:study_prog_data) do
        [
          {
            'student_id'=>'25259127',
            'acadcareer_code'=>'UGRD',
            'term_id'=>'2158',
            'splstudyprog_type_code'=>'BGNNFILING',
            'splstudyprog_type_descr'=>'Filing Fee'
          }
        ]
      end
      let(:enrollment_data) { generate_enrollment_data }
      it 'should add study program data' do
        expect([feed[:semesters][3]]).to all include({hasStudyProgData: true})
      end
    end


    shared_examples 'a good and proper multiple-primary munge' do
      let(:term_keys) { ['2013-D'] }
      let(:enrollment_data) { {'2013-D' => multiple_primary_enrollment_term} }

      let(:classes) { feed[:semesters].first[:classes] }
      let(:multiple_primary_class) { classes.first }
      let(:single_primary_classes) { classes[1..-1] }

      it 'should flag multiple primaries' do
        expect(multiple_primary_class[:multiplePrimaries]).to eq true
        single_primary_classes.each { |c| expect(c).not_to include(:multiplePrimaries) }
      end

      it 'should include slugs and URLs only for primary sections of multiple-primary courses' do
        multiple_primary_class[:sections].each do |s|
          if s[:is_primary_section]
            expect(s[:slug]).to eq "#{s[:instruction_format].downcase}-#{s[:section_number]}"
            expect(s[:url]).to eq "#{multiple_primary_class[:url]}/#{s[:slug]}"
          else
            expect(s).not_to include(:slug)
            expect(s).not_to include(:url)
          end
        end
        single_primary_classes.each do |c|
          c[:sections].each do |s|
            expect(s).not_to include(:slug)
            expect(s).not_to include(:url)
          end
        end
      end

      it 'should associate secondary sections with the correct primaries' do
        expect(multiple_primary_class[:sections][0]).not_to include(:associatedWithPrimary)
        expect(multiple_primary_class[:sections][1]).not_to include(:associatedWithPrimary)
        expect(multiple_primary_class[:sections][2][:associatedWithPrimary]).to eq multiple_primary_class[:sections][0][:slug]
        expect(multiple_primary_class[:sections][3][:associatedWithPrimary]).to eq multiple_primary_class[:sections][1][:slug]
      end
    end

    context 'Campus Solutions multiple-primary munge' do
      before do
        allow(Settings.terms).to receive(:legacy_cutoff).and_return 'summer-2009'
        allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
      end
      let(:multiple_primary_enrollment_term) do
        enrollment_term('2013-D').tap do |term|
          term.first[:sections] = [
            course_enrollment_section(ccn: '10001', is_primary_section: true, format: 'LEC', section_number: '001'),
            course_enrollment_section(ccn: '10002', is_primary_section: true, format: 'LEC', section_number: '002'),
            course_enrollment_section(ccn: '10003', is_primary_section: false, format: 'DIS', section_number: '101', associated_primary_id: '10001'),
            course_enrollment_section(ccn: '10004', is_primary_section: false, format: 'DIS', section_number: '201', associated_primary_id: '10002')
          ]
          term
        end
      end
      it_should_behave_like 'a good and proper multiple-primary munge'
    end

    context 'when a semester has all waitlisted courses, or no enrolled courses' do
      before do
        allow(Settings.terms).to receive(:fake_now).and_return '2016-04-01'
        allow(Settings.terms).to receive(:legacy_cutoff).and_return 'fall-2009'
        expect(CampusOracle::Queries).not_to receive :get_enrolled_sections
        allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
      end
      let(:term_keys) { ['2016-D'] }
      let(:enrollment_data) { {'2016-D' => waitlisted_term} }

      context 'all waitlisted courses' do
        let(:waitlisted_term) do
          enrollment_term('2016-D').tap do |term|
            term.each do |course|
              course[:sections] = [
                course_enrollment_section(is_primary_section: true, waitlisted: true),
                course_enrollment_section(is_primary_section: false, waitlisted: true),
              ]
            end
          end
        end
        it 'should say that there are no enrolled courses' do
          feed[:semesters].each do |semester|
            expect(semester[:hasEnrolledClasses]).to be false
          end
        end
      end

      context 'some waitlisted courses and no reserved seats' do
        before do
          allow_any_instance_of(EdoOracle::Queries).to receive(:get_section_reserved_capacity).and_return([])
        end
        let(:waitlisted_term) do
          enrollment_term('2016-D').tap do |term|
            term.first[:sections] = [
              course_enrollment_section(is_primary_section: true, waitlisted: true),
              course_enrollment_section(is_primary_section: false,waitlisted: true)
            ]
          end
        end
        it 'should say that there are enrolled courses' do
          feed[:semesters].each do |semester|
            expect(semester[:hasEnrolledClasses]).to be true
          end
        end
        it 'should say that there are no reserved seats for all sections' do
          feed[:semesters].each do |semester|
            semester[:classes].each do |course|
              course[:sections].each do |section|
                expect(section[:hasReservedSeats]).to be_nil
              end
            end
          end
        end
      end

      context 'some waitlisted courses with reserved seats' do
        let(:reserved_capacity_data) {
          [
            {
              'term_id' => '2168',
              'class_nbr' => '123456',
              'reserved_seats' => '20',
              'reserved_seats_taken' => '11',
              'requirement_group_descr' => 'Music major'
            },
            {
              'term_id' => '2168',
              'class_nbr' => '123456',
              'reserved_seats' => '30',
              'reserved_seats_taken' => '22',
              'requirement_group_descr' => 'New L&S Transfer Admits'
            },
            {
              'term_id' => '2168',
              'class_nbr' => '123456',
              'reserved_seats' => '40',
              'reserved_seats_taken' => '41',
              'requirement_group_descr' => 'Enrollment by Permission'
            },
          ]
        }
        let(:section_capacity_data) {
          [
            {
              'enrolled_count' => '20',
              'max_enroll' => '50'
            }
          ]
        }
        let(:waitlisted_term) do
          enrollment_term('2016-D').tap do |term|
            term.first[:sections] = [
              course_enrollment_section(waitlisted: true, ccn: '123456'),
              course_enrollment_section(waitlisted: true, ccn: '654321')
            ]
          end
        end
        before do
          allow(EdoOracle::Queries).to receive(:get_section_reserved_capacity).and_return([])
          allow(EdoOracle::Queries).to receive(:get_section_reserved_capacity).with('2168','123456').and_return(reserved_capacity_data)
          allow(EdoOracle::Queries).to receive(:get_section_capacity).and_return(section_capacity_data)
        end
        it 'should say that there are no reserved seats for all sections that are not ccn=123456' do
          feed[:semesters].each do |semester|
            semester[:classes].each do |course|
              course[:sections].each do |section|
                if section[:ccn] != '123456'
                  expect(section[:hasReservedSeats]).to be_nil
                end
              end
            end
          end
        end

        it 'should say that there are reserved seats for all sections that are ccn=123456 in term 2016' do
          feed[:semesters].each do |semester|
            semester[:classes].each do |course|
              course[:sections].each do |section|
                if section[:ccn] == '123456'
                  expect(section[:hasReservedSeats]).to be true
                  expect(semester[:termId]).to eq('2168')

                  expect(section[:capacity]).to be
                  expect(section[:capacity][:unreservedSeats]).to eq('14')
                  expect(section[:capacity][:reservedSeats].length).to eq(3)
                  expect(section[:capacity][:reservedSeats][0][:seats]).to eq('9')
                  expect(section[:capacity][:reservedSeats][0][:seatsFor]).to eq('Music major')
                end
              end
            end
          end
        end

        it 'should say N/A when there are negative reserved seats for sections that are ccn=123456 in term 2016' do
          feed[:semesters].each do |semester|
            semester[:classes].each do |course|
              course[:sections].each do |section|
                if section[:ccn] == '123456'
                  expect(section[:hasReservedSeats]).to be true
                  expect(semester[:termId]).to eq('2168')
                  expect(section[:capacity][:reservedSeats][2][:seats]).to eq('N/A')
                end
              end
            end
          end
        end
      end
    end

    describe 'merging grade data' do
      before do
        allow(Settings.terms).to receive(:fake_now).and_return(fake_now)
        allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
      end

      let(:term_yr) { '2016' }
      let(:term_cd) { 'B' }
      let(:enrollment_data) { generate_enrollment_data  }
      let(:feed_semester) { feed[:semesters].find { |s| s[:name] == Berkeley::TermCodes.to_english(term_yr, term_cd) } }
      let(:feed_semester_grades) { feed_semester[:classes].map { |course| course[:sections].map {|s| s[:grading] if s[:is_primary_section]}.compact }.flatten! }

      shared_examples 'grades from enrollment' do
        it 'returns enrollment grades' do
          grades_from_enrollment = enrollment_data["#{term_yr}-#{term_cd}"].map { |e| e[:sections].map{ |s| s[:grading] if s[:is_primary_section] }.compact }.flatten!
          expect(feed_semester_grades).to match_array grades_from_enrollment
        end
      end

      shared_examples 'grading in progress' do
        it { expect(feed_semester[:gradingInProgress]).to be_truthy }
      end

      shared_examples 'grading not in progress' do
        it { expect(feed_semester[:gradingInProgress]).to be_nil }
      end

      context 'current semester' do
        let(:fake_now) {DateTime.parse('2016-04-10')}
        include_examples 'grades from enrollment'
        include_examples 'grading not in progress'
      end

      context 'semester just ended' do
        let(:fake_now) {DateTime.parse('2016-05-22')}
        include_examples 'grades from enrollment'
        include_examples 'grading in progress'
      end

      context 'past semester' do
        let(:fake_now) {DateTime.parse('2016-08-10')}
        include_examples 'grading not in progress'
      end
    end

    context 'filtered view for delegate' do
      def enrollment_summary_term(key)
        rand(2..4).times.map { enrollment_summary(key) }
      end

      def enrollment_summary(key)
        enrollment = course_enrollment key
        enrollment[:sections].map! { |section| section.except(:instructors, :schedules) }
        enrollment
      end

      let(:feed) { {filteredForDelegate: true}.tap { |feed| MyAcademics::Semesters.new(random_id).merge(feed) } }
      let(:enrollment_data) { generate_enrollment_data }
      let(:enrollment_summary_data) { Hash[term_keys.map{|key| [key, enrollment_summary_term(key)]}] }
      before do
        allow(Settings.terms).to receive(:legacy_cutoff).and_return 'summer-2014'
        allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_enrollments_summary).and_return enrollment_summary_data
      end

      include_examples 'semester ordering'

      it 'should preserve structure of enrollment summary data' do
        feed[:semesters].each do |s|
          expect(s[:hasEnrollmentData]).to eq true
          expect(s).to include :slug
          enrollment_semester = enrollment_summary_data["#{s[:termYear]}-#{s[:termCode]}"]
          expect(s[:classes].length).to eq enrollment_semester.length
          s[:classes].each do |course|
            matching_enrollment = enrollment_semester.find { |e| e[:id] == course[:course_id] }
            expect(course[:sections].count).to eq matching_enrollment[:sections].count
            expect(course[:title]).to eq matching_enrollment[:name]
            expect(course[:courseCatalog]).to eq matching_enrollment[:course_catalog]
            [:course_code, :dept, :dept_desc, :role, :slug, :session_code].each do |key|
              expect(course[key]).to eq matching_enrollment[key]
            end
          end
        end
      end

      it 'should filter out course URLs' do
        feed[:semesters].each do |s|
          s[:classes].each do |course|
            expect(course).not_to include :url
          end
        end
      end

      it 'should flag it as filtered for delegate' do
        feed[:semesters].each do |s|
          expect(s[:filteredForDelegate]).to eq true
        end
      end

    end
  end
end
