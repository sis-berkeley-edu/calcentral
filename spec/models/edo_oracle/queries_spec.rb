describe EdoOracle::Queries do
  shared_examples 'a successful query' do
    it 'returns a set of rows' do
      expect(subject).to be
      expect(subject).to be_a Array
    end
  end

  shared_examples 'a successful query that returns one result' do
    it 'returns a single row' do
      expect(subject).to be
      expect(subject).to be_a Hash
    end
  end

  before do
    allow(Settings.edodb).to receive(:fake).and_return false
    allow(Settings.terms).to receive(:fake_now).and_return nil
    allow(Settings.terms).to receive(:use_term_definitions_json_file).and_return true
    allow(Settings.features).to receive(:hub_term_api).and_return false
  end

  it_behaves_like 'an Oracle driven data source' do
    subject { described_class }
  end

  it 'is configured correctly' do
    expect(described_class.settings).to be Settings.edodb
  end

  describe '#get_term_unit_totals', testext: false do
    subject { described_class.get_term_unit_totals(uid, academic_careers, term_id) }
    let(:uid) { 799934 }
    let(:academic_careers) { ['UGRD'] }
    let(:term_id) { 2178 }

    it_behaves_like 'a successful query that returns one result'

    it 'returns the expected result' do
      expect(subject.count).to eq 3
      expect(subject['total_earned_units']).to eq 96.67
      expect(subject['total_enrolled_units']).to eq 6
      expect(subject['grading_complete']).to eq 'Y'
    end
  end

  describe '#get_term_law_unit_totals', testext: false do
    subject { described_class.get_term_law_unit_totals(uid, academic_careers, term_id) }
    let(:uid) { 300216 }
    let(:academic_careers) { %w(GRAD LAW) }
    let(:term_id) { 2172 }

    it_behaves_like 'a successful query that returns one result'

    it 'returns the expected result' do
      expect(subject.count).to eq 2
      expect(subject['total_earned_law_units']).to eq 15
      expect(subject['total_enrolled_law_units']).to eq 18
    end
  end

  describe '#get_careers', testext: false do
    subject { described_class.get_careers(uid) }
    let(:uid) { 300216 }

    it_behaves_like 'a successful query'

    it 'returns the expected result' do
      expect(subject.count).to eq 3
      expect(subject[0]).to be
      expect(subject[1]).to be
      expect(subject[2]).to be

      expect(subject[0]['acad_career']).to eq 'GRAD'
      expect(subject[0]['program_status']).to eq 'AC'
      expect(subject[0]['total_cumulative_units']).to eq 16
      expect(subject[0]['total_cumulative_law_units']).to eq 0

      expect(subject[1]['acad_career']).to eq 'LAW'
      expect(subject[1]['program_status']).to eq 'AC'
      expect(subject[1]['total_cumulative_units']).to eq 61
      expect(subject[1]['total_cumulative_law_units']).to eq 46

      expect(subject[2]['acad_career']).to eq 'UGRD'
      expect(subject[2]['program_status']).to be_falsey
      expect(subject[2]['total_cumulative_units']).to eq 157
      expect(subject[2]['total_cumulative_law_units']).to eq 0
    end
  end

  describe '#get_enrolled_sections', testext: false do
    subject { described_class.get_enrolled_sections(uid, terms) }
    let(:uid) { 799934 }
    let(:terms) { nil }

    it_behaves_like 'a successful query'

    it 'returns the expected result' do
      expect(subject.count).to eq 3
      expect(subject.first.count).to eq 29
      expect(subject.first['section_id']).to eq '12392'
      expect(subject.first['term_id']).to eq '2178'
      expect(subject.first['session_id']).to eq '1'
      expect(subject.first['course_title']).to eq 'Senior Seminar'
      expect(subject.first['course_title_short']).to eq 'SENIOR SEMINAR'
      expect(subject.first['dept_name']).to eq 'AMERSTD'
      expect(subject.first['dept_code']).to eq 'AMERSTD'
      expect(subject.first['course_career_code']).to eq 'UGRD'
      expect(subject.first['primary']).to eq 'TRUE'
      expect(subject.first['section_num']).to eq '3'
      expect(subject.first['instruction_format']).to eq 'SEM'
      expect(subject.first['primary_associated_section_id']).to eq 12392
      expect(subject.first['section_display_name']).to eq 'AMERSTD 191'
      expect(subject.first['topic_description']).to be nil
      expect(subject.first['course_display_name']).to eq 'AMERSTD 191'
      expect(subject.first['catalog_id']).to eq '191'
      expect(subject.first['catalog_root']).to eq '191'
      expect(subject.first['catalog_prefix']).to be nil
      expect(subject.first['catalog_suffix']).to be nil
      expect(subject.first['enroll_limit']).to eq 20
      expect(subject.first['enroll_status']).to eq 'E'
      expect(subject.first['waitlist_position']).to be nil
      expect(subject.first['units_taken']).to eq 1
      expect(subject.first['units_earned']).to eq 1
      expect(subject.first['grade']).to eq 'P'
      expect(subject.first['grade_points']).to eq 0
      expect(subject.first['grading_basis']).to eq 'PNP'
      expect(subject.first['acad_career']).to eq 'UGRD'
      expect(subject.first['rqmnt_designtn']).to be nil
    end
    context 'when a class has a requirements designation' do
      let(:uid) { 490452 }
      context 'and the course career is not LAW' do
        it 'does not provide the requirements designation' do
          expect(subject[0]['rqmnt_designtn']).to be nil
        end
      end
      context 'and the course career is LAW' do
        it 'provides the requirements designation' do
          expect(subject[1]['rqmnt_designtn']).to eq 'LPR'
        end
      end
    end
    context 'when constrained by terms' do
      before do
        allow(Settings.features).to receive(:hub_term_api).and_return true
      end
      let(:term) do
        {
          'term_yr' => '2017',
          'term_cd' => 'D',
          'term_status' => 'FT',
          'term_status_desc' => 'Current Fall',
          'term_name' => 'Fall',
          'current_tb_term_flag' => 'N',
          'term_start_date' => Time.parse('2017-08-16 00:00:00 UTC'),
          'term_end_date' => Time.parse('2017-12-15 00:00:00 UTC')
        }
      end
      let(:terms) { [Berkeley::Term.new(term)] }
      it_behaves_like 'a successful query'
      it 'returns only enrollments belonging to the specified terms' do
        expect(subject.count).to eq 2
        expect(subject[0]['term_id']).to eq '2178'
        expect(subject[1]['term_id']).to eq '2178'
      end
    end
    context 'when no UID provided' do
      let(:uid) { nil }
      it_behaves_like 'a successful query'
    end
    context 'when no data exists for UID' do
      let(:uid) { 1 }
      it_behaves_like 'a successful query'
    end
  end

  describe '.get_instructing_sections', testext: false do
    let(:term) { Berkeley::Terms.fetch.campus['fall-2018'] }
    let(:uid) { '27' }
    subject { described_class.get_instructing_sections(uid, [term]) }
    it 'returns the expected result' do
      expect(subject.count).to eq 1
      expect(subject.first['section_id']).to eq '12392'
      expect(subject.first['term_id']).to eq '2188'
      expect(subject.first['session_id']).to eq '1'
      expect(subject.first['course_title']).to eq 'Supervised Research: Biological Sciences'
      expect(subject.first['course_title_short']).to eq 'RESEARCH BIOL SCI'
      expect(subject.first['course_career_code']).to eq 'UGRD'
      expect(subject.first['dept_name']).to eq 'UGIS'
      expect(subject.first['dept_code']).to eq 'UGIS'
      expect(subject.first['primary']).to eq 'TRUE'
      expect(subject.first['section_num']).to eq '16'
      expect(subject.first['instruction_format']).to eq 'TUT'
      expect(subject.first['primary_associated_section_id']).to eq 12392
      expect(subject.first['section_display_name']).to eq 'UGIS 192C'
      expect(subject.first['topic_description']).to be nil
      expect(subject.first['course_display_name']).to eq 'UGIS 192C'
      expect(subject.first['catalog_id']).to eq '192C'
      expect(subject.first['catalog_root']).to eq '192'
      expect(subject.first['catalog_prefix']).to be nil
      expect(subject.first['catalog_suffix']).to eq 'C'
      expect(subject.first['enroll_limit']).to eq 30.0
      expect(subject.first['waitlist_limit']).to eq 30.0
      expect(subject.first['start_date']).to eq Date.parse('Wed, 22 Aug 2018')
      expect(subject.first['end_date']).to eq Date.parse('Fri, 07 Dec 2018')
    end

    describe '.get_section_final_exams', testext: false do
      let(:term_id) { '2178' }
      let(:section_id) { '11950' }
      subject { described_class.get_section_final_exams(term_id, section_id) }
      it 'returns the expected result' do
        expect(subject[0]['term_id']).to eq '2178'
        expect(subject[0]['session_id']).to eq '1'
        expect(subject[0]['section_id']).to eq '11950'
        expect(subject[0]['exam_type']).to eq 'N'
        expect(subject[0]['exam_date']).to eq Date.parse('Thu, 17 Dec 2015')
        expect(subject[0]['exam_start_time'].utc).to be
        expect(subject[0]['exam_end_time'].utc).to be
        expect(subject[0]['location']).to eq 'Hearst Gym 188'
        expect(subject[0]['exam_exception']).to eq 'Y'
        expect(subject[0]['finalized']).to eq 'N'
      end
    end
  end

  describe '#get_law_enrollment', testext: false do
    subject { described_class.get_law_enrollment(uid, academic_career, term, section, require_desig_code) }
    let (:uid) { 490452 }
    let (:academic_career) { 'LAW' }
    let (:term) { 2185 }
    let (:section) { 11950 }
    let (:require_desig_code) { 'LPR' }

    it_behaves_like 'a successful query that returns one result'

    it 'returns the expected result' do
      expect(subject.count).to eq 3
      expect(subject['units_taken_law']).to eq 3
      expect(subject['units_earned_law']).to eq 0
      expect(subject['rqmnt_desg_descr']).to eq 'Fulfills Professional Responsibility Requirement'
    end
  end

  describe '#get_concurrent_student_status' do
    subject { described_class.get_concurrent_student_status(student_id) }
    let (:student_id) { 95727964 }

    it_behaves_like 'a successful query that returns one result'

    it 'returns the expected result' do
      expect(subject['concurrent_status']).to eq 'Y'
    end
  end

  describe '#get_transfer_credit_detailed', testext: false do
    subject { EdoOracle::Queries.get_transfer_credit_detailed(uid) }
    let(:uid) { 300216 }

    it_behaves_like 'a successful query'

    it 'returns the expected result' do
      expect(subject.count).to eq 3
      expect(subject[0]).to have_keys(['career', 'school_descr', 'transfer_units', 'law_transfer_units', 'requirement_designation', 'grade_points'])
      expect(subject[1]).to have_keys(['career', 'school_descr', 'transfer_units', 'law_transfer_units', 'requirement_designation', 'grade_points'])
      expect(subject[2]).to have_keys(['career', 'school_descr', 'transfer_units', 'law_transfer_units', 'requirement_designation', 'grade_points'])
    end
  end

  describe '#get_housing' do
    subject { EdoOracle::Queries.get_housing(uid, aid_year) }
    let(:uid) { 61889 }
    let(:aid_year) { 2019 }

    it_behaves_like 'a successful query'

    it 'returns the expected result' do
      expect(subject.count).to eq 2
      expect(subject[0]).to have_keys(%w(term_id term_descr housing_option housing_status housing_end_date acad_career))
      expect(subject[1]).to have_keys(%w(term_id term_descr housing_option housing_status housing_end_date acad_career))
    end
    it 'sorts the rows by term ID' do
      expect(subject[0]['term_id']).to eq '2188'
      expect(subject[1]['term_id']).to eq '2192'
    end
  end

  context 'when connecting to an external database', :ignore => true do
    # Stubbing terms not available in TestExt env
    let(:summer_2016_db_term) do
      {
        'term_yr' => '2016',
        'term_cd' => 'C',
        'term_status' => 'CS',
        'term_status_desc' => 'Current Summer',
        'term_name' => 'Summer',
        'current_tb_term_flag' => 'N',
        'term_start_date' => Time.parse('2016-05-23 00:00:00 UTC'),
        'term_end_date' => Time.parse('2016-08-12 00:00:00 UTC')
      }
    end
    let(:fall_2016_db_term) do
      {
        'term_yr' => '2016',
        'term_cd' => 'D',
        'term_status' => 'FT',
        'term_status_desc' => 'Future Term',
        'term_name' => 'Fall',
        'current_tb_term_flag' => 'Y',
        'term_start_date' => Time.parse('2016-08-13 00:00:00 UTC'),
        'term_end_date' => Time.parse('2016-12-31 00:00:00 UTC')
      }
    end
    let(:terms) { [Berkeley::Term.new(fall_2016_db_term), Berkeley::Term.new(summer_2016_db_term)] }
    let(:fall_term_id) { terms[0].campus_solutions_id }

    # BIOLOGY 1A - Fall 2016
    let(:section_ids) { %w(13572 31352) }

    it_behaves_like 'an Oracle driven data source' do
      subject { EdoOracle::Queries }
    end

    it 'provides settings' do
      expect(EdoOracle::Queries.settings).to be Settings.edodb
    end

    describe '.terms_query_list' do
      context 'when no terms present' do
        it 'returns empty string' do
          expect(EdoOracle::Queries.terms_query_list).to eq ''
        end
      end
      context 'when terms present' do
        it 'returns term list for sql' do
          expect(EdoOracle::Queries.terms_query_list(terms)).to eq "'2105','2108'"
        end
      end
    end

    describe '.get_instructing_sections', testext: true do
      let(:term) { Berkeley::Terms.fetch.campus['spring-2010'] }
      let(:uid) { '30' }
      it 'fetches expected data' do
        results = EdoOracle::Queries.get_instructing_sections(uid, [term])
        expect(results.count).to eq 17
        expected_keys = %w(course_title course_title_short dept_name catalog_id primary section_num instruction_format primary_associated_section_id catalog_root catalog_prefix catalog_suffix enroll_limit waitlist_limit)
        results.each do |result|
          expect(result['term_id']).to eq '2102'
          expect(result).to have_keys(expected_keys)
        end
      end
    end

    describe '.get_instructing_legacy_terms' do
      let(:person_id) { '7093' }
      it 'fetches expected data' do
        results = EdoOracle::Queries.get_instructing_legacy_terms(person_id)
        expect(results.count).to eq 3
        expect(results[0]['term_id']).to eq '2072'
        expect(results[1]['term_id']).to eq '2068'
        expect(results[2]['term_id']).to eq '2065'
      end
    end

    describe '.get_enrolled_sections', testext: true do
      let(:term) { Berkeley::Terms.fetch.campus['spring-2010'] }
      let(:uid) { '767911' }
      it 'fetches expected data' do
        results = EdoOracle::Queries.get_enrolled_sections(uid, [term])
        expect(results.count).to eq 5
        expected_keys = %w(section_id term_id session_id course_title course_title_short dept_name primary section_num instruction_format primary_associated_section_id course_display_name section_display_name catalog_id catalog_root catalog_prefix catalog_suffix enroll_limit enroll_status waitlist_position units grade grading_basis)
        results.each do |result|
          expect(result['term_id']).to eq '2102'
          expect(result).to have_keys(expected_keys)
        end
      end
    end

    describe '.get_sections_by_ids', :testext => true do
      it 'returns sections specified by id array' do
        results = EdoOracle::Queries.get_sections_by_ids(fall_term_id, section_ids)
        expect(results.count).to eq 2
        expect(results[0]['section_id']).to eq '13572'
        expect(results[1]['section_id']).to eq '31352'
        expected_keys = %w(course_title course_title_short dept_name catalog_id primary section_num instruction_format primary_associated_section_id catalog_root catalog_prefix catalog_suffix)
        results.each do |result|
          expect(result['term_id']).to eq '2168'
          expected_keys.each do |expected_key|
            expect(result).to have_key(expected_key)
          end
        end
      end
    end

    describe '.get_associated_secondary_sections', :testext => true do
      it 'returns a set of secondary sections' do
        results = EdoOracle::Queries.get_associated_secondary_sections(fall_term_id, '31586')
        expect(results).to be_present
        expected_keys = %w(session_id course_title course_title_short dept_name catalog_id primary section_num instruction_format primary_associated_section_id catalog_root catalog_prefix catalog_suffix)
        results.each do |result|
          expect(result).to have_keys(expected_keys)
          expect(result['section_display_name']).to eq 'ESPM 155AC'
          expect(result['instruction_format']).to eq 'DIS'
          expect(result['primary']).to eq 'false'
          expect(result['term_id']).to eq fall_term_id
        end
      end
    end

    describe '.get_section_meetings', :testext => true do
      it 'returns meetings for section id specified' do
        results = EdoOracle::Queries.get_section_meetings(fall_term_id, section_ids[0])
        expect(results.count).to eq 1
        expected_keys = %w(section_id term_id session_id location meeting_days meeting_start_time meeting_end_time print_in_schedule_of_classes meeting_start_date meeting_end_date)
        results.each do |result|
          expect(result['section_id']).to eq '26340'
          expect(result['term_id']).to eq '2168'
          expect(result['print_in_schedule_of_classes']).to eq 'Y'
          expect(result).to have_keys(expected_keys)
        end
      end
    end

    describe '.get_section_final_exam', :testext => true do
      it 'returns exams for section id specified' do
        results = EdoOracle::Queries.get_section_final_exam(fall_term_id, section_ids[0])
        expect(results.count).to eq 1
        expected_keys = %w(term_id session_id section_id exam_type exam_date exam_start_time exam_end_time location)
        results.each do |result|
          expect(result['term_id']).to eq '2168'
          expect(result['exam_date']).to eq Time.parse('2016-12-12 00:00:00 UTC')
          expect(result).to have_keys(expected_keys)
        end
      end
    end

    describe '.get_section_instructors', :testext => true do
      let(:expected_keys) { %w(person_name first_name last_name ldap_uid role_code role_description) }
      it 'returns instructors for section' do
        results = EdoOracle::Queries.get_section_instructors(fall_term_id, section_ids[0])
        results.each do |result|
          expect(result).to have_keys(expected_keys)
        end
      end
    end

    describe '.terms', :testext => true do
      let(:expected_keys) { %w(term_code term_name term_start_date term_end_date) }
      it 'returns terms' do
        results = EdoOracle::Queries.terms
        results.each do |result|
          expect(result).to have_keys(expected_keys)
        end
        result_codes = results.collect { |result| result['term_code'] }
        # check for Spring 2015 - Summer 2017 terms
        expect(result_codes).to include('2152', '2155', '2158', '2162', '2165', '2168', '2172', '2175')
      end
    end

    describe '.get_cross_listed_course_title', :testext => true do
      it 'returns cross-listed course title' do
        result = EdoOracle::Queries.get_cross_listed_course_title('S,SEASN C112')
        expect(result['title']).to eq 'The British Empire and Commonwealth'
        expect(result['transcriptTitle']).to eq 'BRITISH EMPIRE'
      end
    end

    describe '.get_subject_areas', :testext => true do
      it 'returns subject areas' do
        results = EdoOracle::Queries.get_subject_areas
        subject_areas = results.map { |result| result['subjectarea'] }
        expect(subject_areas).to all(be_present)
        expect(subject_areas).to include('DES INV', 'DEV ENG', 'ENE,RES', 'EL ENG', 'L & S', 'MEC ENG', 'XL&S')
      end
    end

    describe '.get_enrolled_students', :testext => true do
      let(:expected_keys) { %w(ldap_uid student_id enroll_status waitlist_position units grading_basis) }
      it 'returns enrollments for section' do
        results = EdoOracle::Queries.get_enrolled_students(section_ids[0], fall_term_id)
        results.each do |enrollment|
          expect(enrollment).to have_keys(expected_keys)
        end
      end
    end

    describe '.get_rosters', :testext => true do
      let(:expected_keys) { %w(section_id ldap_uid student_id enroll_status waitlist_position units grading_basis major academic_career terms_in_attendance_group statusinplan_status_code) }
      it 'returns enrollments for section' do
        results = EdoOracle::Queries.get_rosters(section_ids, fall_term_id)
        results.each do |enrollment|
          expect(enrollment).to have_keys(expected_keys)
        end
      end
    end

    describe '.has_instructor_history?', :testext => true do
      subject { EdoOracle::Queries.has_instructor_history?(ldap_uid, terms) }
      context 'when user is an instructor' do
        let(:ldap_uid) { '172701' } # Leah A Carroll - Haas Scholars Program Manager and Advisor
        context 'when terms array is empty' do
          let(:terms) { [] }
          it {should eq true}
        end
        it {should eq true}
      end
      context 'when user is not an instructor' do
        let(:ldap_uid) { '211159' } # Ray Davis - staff / developer
        context 'when terms array is empty' do
          let(:terms) { [] }
          it {should eq false}
        end
        it {should eq false}
      end
    end

    describe '.has_student_history?', :testext => true do
      subject { EdoOracle::Queries.has_student_history?(ldap_uid, terms) }
      context 'when user has a student history' do
        let(:ldap_uid) { '184270' }
        context 'when terms array is empty' do
          let(:terms) { [] }
          it {should eq true}
        end
        it {should eq true}
      end
      context 'when user does not have a student history' do
        let(:ldap_uid) { '211159' } # Ray Davis - staff / developer
        context 'when terms array is empty' do
          let(:terms) { [] }
          it {should eq false}
        end
        it {should eq false}
      end
    end

    describe '.get_grading_dates', :testext => false do
      subject { EdoOracle::Queries.get_grading_dates }
      it 'returns grading dates' do
        expect(subject.count).to eq 3
      end
    end

    describe '.get_student_term_cpp', testext: false do
      subject { EdoOracle::Queries.get_student_term_cpp(student_id) }
      context 'when valid uid' do
        let(:oski_sid) { '11667051' }
        let(:student_id) { oski_sid }
        it 'should return term cpp records' do
          expect(subject.count).to_not eq 0
          expect(subject[0]).to have_keys(['term_id', 'acad_career', 'acad_program', 'acad_plan'])
        end
      end
    end
  end
end
