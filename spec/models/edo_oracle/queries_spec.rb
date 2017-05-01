describe EdoOracle::Queries, :ignore => true do
  # These tests go against the DB, which could change at any time, and thus is not included in Travis.
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

end
