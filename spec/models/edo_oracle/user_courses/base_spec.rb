describe EdoOracle::UserCourses::Base do

  RSpec::Matchers.define :terms_following_and_including_cutoff do |cutoff|
    match do |terms|
      term_ids = terms.map &:campus_solutions_id
      term_ids.present? && term_ids.all? { |term_id| term_id >= cutoff }
    end
  end

  it 'should query non-legacy terms only' do
    allow(Settings.terms).to receive(:legacy_cutoff).and_return 'summer-2013'
    expect(EdoOracle::Queries).to receive(:get_enrolled_sections).with(anything, terms_following_and_including_cutoff('2135')).and_return []
    described_class.new(user_id: random_id).merge_enrollments({})
  end

  let(:base_course_data) do
    {
      'catalog_id' => '74',
      'catalog_prefix' => nil,
      'catalog_root' => '74',
      'catalog_suffix' => nil,
      'course_display_name' => 'MUSIC 74',
      'course_title' => 'Introduction to Selected Musics of the World',
      'course_title_short' => 'INTR MUSICS WORLD',
      'dept_name' => 'MUSIC',
      'section_display_name' => 'MUSIC 74',
      'term_id' => '2168',
    }
  end

  let(:subject_areas) { ['MEC ENG', 'MUSIC'] }
  before do
    allow(EdoOracle::Queries).to receive(:get_subject_areas).and_return subject_areas.map { |area| {'subjectarea' => area} }
  end

  describe 'enrolled sections merge' do
    let(:enrollment_query_results) do
      [
        base_course_data.merge({
          'enroll_limit' => '40',
          'enroll_status' => 'E',
          'grade' => 'B',
          'grading_basis' => 'GRD',
          'instruction_format' => 'LEC',
          'primary' => 'true',
          'primary_associated_section_id' => '44203',
          'section_id' => '44203',
          'section_num' => '001',
          'units' => '4',
          'wait_list_seq_num' => nil
        }),
        base_course_data.merge({
          'enroll_limit' => '50',
          'enroll_status' => 'W',
          'grade' => nil,
          'grading_basis' => 'PNP',
          'instruction_format' => 'LEC',
          'primary' => 'true',
          'primary_associated_section_id' => '44206',
          'section_id' => '44206',
          'section_num' => '002',
          'units' => '3',
          'wait_list_seq_num' => nil
        }),
        base_course_data.merge({
          'enroll_limit' => '40',
          'enroll_status' => 'E',
          'grade' => nil,
          'grading_basis' => nil,
          'instruction_format' => 'DIS',
          'primary' => 'false',
          'primary_associated_section_id' => '44201',
          'section_id' => '44214',
          'section_num' => '201',
          'units' => nil,
          'wait_list_seq_num' => nil
        }),
        base_course_data.merge({
          'enroll_limit' => '40',
          'enroll_status' => 'E',
          'grade' => nil,
          'grading_basis' => nil,
          'instruction_format' => 'DIS',
          'primary' => 'false',
          'primary_associated_section_id' => '44203',
          'section_id' => '44214',
          'section_num' => '201',
          'units' => nil,
          'wait_list_seq_num' => nil
        })
      ]
    end
    before do
      allow(Settings.terms).to receive(:legacy_cutoff).and_return 'summer-2013'
      expect(EdoOracle::Queries).to receive(:get_enrolled_sections).and_return enrollment_query_results
    end
    let(:feed) { {}.tap { |feed| EdoOracle::UserCourses::Base.new(user_id: random_id).merge_enrollments feed } }
    subject { feed['2016-D'] }
    its(:size) { should eq 1 }
    let(:course) { subject.first }
    it 'includes only course info at the course level' do
      expect(course[:catid]).to eq '74'
      expect(course[:course_catalog]).to eq '74'
      expect(course[:course_code]).to eq 'MUSIC 74'
      expect(course[:dept]).to eq 'MUSIC'
      expect(course[:emitter]).to eq 'Campus'
      expect(course[:id]).to eq 'music-74-2016-D'
      expect(course[:name]).to eq 'Introduction to Selected Musics of the World'
      expect(course[:role]).to eq 'Student'
      expect(course[:slug]).to eq 'music-74'
      expect(course[:term_cd]).to eq 'D'
      expect(course[:term_id]).to eq '2168'
      expect(course[:term_yr]).to eq '2016'
    end
    it 'does not include instructor-specific data' do
      expect(course).not_to include :enroll_limit
      expect(course).not_to include :waitlist_limit
    end
    it 'de-duplicates sections differing only by primary_associated_section_id' do
      expect(course[:sections].size).to eq 3
    end
    context 'some rows missing course name' do
      before do
        enrollment_query_results.first.delete 'course_title'
        enrollment_query_results.first.delete 'course_title_short'
      end
      it 'prefers present to blank course title' do
        expect(course[:name]).to eq 'Introduction to Selected Musics of the World'
      end
    end
    it 'prefers a primary_associated_section_id matching a section in the result set' do
      expect(course[:sections][2][:associated_primary_id]).to eq '44203'
    end
    it 'includes per-section information' do
      [course[:sections], enrollment_query_results[0..2]].transpose.each do |section, enrollment|
        expect(section[:ccn]).to eq enrollment['section_id']
        expect(section[:instruction_format]).to eq enrollment['instruction_format']
        expect(section[:section_label]).to eq "#{enrollment['instruction_format']} #{enrollment['section_num']}"
        expect(section[:section_number]).to eq enrollment['section_num']
        if (enrollment['primary'] == 'true')
          expect(section[:grading_basis]).to eq enrollment['grading_basis']
          expect(section[:is_primary_section]).to eq true
          expect(section[:units]).to eq enrollment['units']
        else
          expect(section[:is_primary_section]).to eq false
          expect(section).not_to include(:grading_basis, :units)
        end
        if enrollment['enroll_status'] == 'W'
          expect(section[:enroll_limit]).to eq enrollment['enroll_limit'].to_i
          expect(section[:waitlistPosition]).to eq enrollment['wait_list_seq_num'].to_i
          expect(section[:waitlisted]).to eq true
        else
          expect(section).not_to include(:enroll_limit, :waitlistPosition, :waitlisted)
        end
        expect(section).not_to include :cross_listing_hash
      end
    end
    it 'includes only non-blank grades' do
      expect(course[:sections][0][:grade]).to eq 'B'
      expect(course[:sections][1]).not_to include(:grade)
    end
    context 'when cross-listed course is missing title' do
      before do
        enrollment_query_results.each do |result|
          result.merge!({
            'catalog_id' => 'C74',
            'catalog_prefix' => 'C',
            'course_display_name' => 'MUSIC C74',
            'course_title' => nil,
            'course_title_short' => nil,
            'section_display_name' => 'MUSIC C74'
          })
        end
      end
      it 'makes an additional database query for the title' do
        expect(EdoOracle::Queries).to receive(:get_cross_listed_course_title).and_return({
          'course_title' => 'George Frideric Handel as Venture Capitalist',
          'course_title_short' => 'GFH VC'
        })
        expect(course[:name]).to eq 'George Frideric Handel as Venture Capitalist'
      end
    end
  end

  describe 'instructing sections merge' do
    let(:instructing_query_results) do
      [
        base_course_data.merge({
          'cs_course_id' => '20001',
          'catalog_id' => '99C',
          'catalog_prefix' => nil,
          'catalog_root' => '99',
          'catalog_suffix' => 'C',
          'course_display_name' => 'MUSIC 99C',
          'course_title' => 'The Stooges in Context',
          'course_title_short' => 'STGS CNTXT',
          'dept_name' => 'MUSIC',
          'enroll_limit' => 40,
          'instruction_format' => 'LEC',
          'primary' => 'true',
          'section_display_name' => 'MUSIC 99C',
          'section_id' => '44807',
          'section_num' => '001',
          'waitlist_limit' => 10
        }),
        base_course_data.merge({
          'cs_course_id' => '30001',
          'catalog_id' => 'C105',
          'catalog_prefix' => 'C',
          'catalog_root' => '99',
          'catalog_suffix' => nil,
          'course_display_name' => 'MUSIC C105',
          'course_title' => 'Einstuerzende Neubauten and Structural Failure',
          'course_title_short' => 'KOLLAPS',
          'dept_name' => 'MUSIC',
          'enroll_limit' => 35,
          'instruction_format' => 'LEC',
          'primary' => 'true',
          'section_display_name' => 'MUSIC C105',
          'section_id' => '45807',
          'section_num' => '001',
          'waitlist_limit' => 9
        }),
        base_course_data.merge({
          'cs_course_id' => '30001',
          'catalog_id' => 'C112',
          'catalog_prefix' => 'C',
          'catalog_root' => '112',
          'catalog_suffix' => nil,
          'course_display_name' => 'MEC ENG C112',
          'course_title' => 'Einstuerzende Neubauten and Structural Failure',
          'course_title_short' => 'KOLLAPS',
          'dept_name' => 'MEC ENG',
          'enroll_limit' => 35,
          'instruction_format' => 'LEC',
          'primary' => 'true',
          'section_display_name' => 'MEC ENG C112',
          'section_id' => '54807',
          'section_num' => '001',
          'waitlist_limit' => 9
        }),
        base_course_data.merge({
          'cs_course_id' => '10001',
          'enroll_limit' => 23,
          'instruction_format' => 'LEC',
          'primary' => 'true',
          'section_id' => '44206',
          'section_num' => '001',
          'waitlist_limit' => 6
        }),
        base_course_data.merge({
          'cs_course_id' => '10001',
          'enroll_limit' => 24,
          'instruction_format' => 'LEC',
          'primary' => 'true',
          'section_id' => '44207',
          'section_num' => '002',
          'waitlist_limit' => 7
        })
      ]
    end
    let(:secondary_query_results) do
      [
        base_course_data.merge({
          'cs_course_id' => '10001',
          'enroll_limit' => 20,
          'instruction_format' => 'DIS',
          'primary' => 'false',
          'section_id' => '44210',
          'section_num' => '201',
          'waitlist_limit' => 5
        }),
        base_course_data.merge({
          'cs_course_id' => '10001',
          'enroll_limit' => 20,
          'instruction_format' => 'DIS',
          'primary' => 'false',
          'section_id' => '44211',
          'section_num' => '202',
          'waitlist_limit' => 5
        }),
        base_course_data.merge({
          'cs_course_id' => '10001',
          'enroll_limit' => 20,
          'instruction_format' => 'DIS',
          'primary' => 'false',
          'section_id' => '44211',
          'section_num' => '202',
          'waitlist_limit' => 5
        })
      ]
    end
    before do
      allow(Settings.terms).to receive(:legacy_cutoff).and_return 'summer-2013'
      expect(EdoOracle::Queries).to receive(:get_instructing_sections).and_return instructing_query_results
      expect(EdoOracle::Queries).to receive(:get_associated_secondary_sections).with('2168', '44207').and_return secondary_query_results
      %w(44206 44807 45807 54807).each do |primary_section_id|
        expect(EdoOracle::Queries).to receive(:get_associated_secondary_sections).with('2168', primary_section_id).and_return []
      end
    end
    let(:feed) { {}.tap { |feed| EdoOracle::UserCourses::Base.new(user_id: random_id).merge_instructing feed } }
    subject { feed['2016-D'] }

    def get_course(course_code)
      subject.find { |course| course[:course_code] == course_code }
    end

    def get_sections(course_code)
      get_course(course_code)[:sections]
    end

    shared_examples 'proper section sorting' do
      it 'sorts out sections based on course code' do
        expect(subject).to have(4).items
        expect(get_sections 'MUSIC 74').to have(4).items
        expect(get_sections 'MUSIC 99C').to have(1).items
        expect(get_sections 'MUSIC C105').to have(1).items
        expect(get_sections 'MEC ENG C112').to have(1).items
      end
    end
    include_examples 'proper section sorting'

    context 'when course codes have bad formatting' do
      let(:mec_eng_result) { instructing_query_results[2] }
      before { mec_eng_result['section_display_name'] = 'MECENG C112' }
      shared_examples 'compensation for bad formatting' do
        include_examples 'proper section sorting'
        it 'deduces correct course codes' do
          mec_eng_course = subject.find { |course| course[:course_code] == 'MEC ENG C112' }
          expect(mec_eng_course).to include({
            catid: 'C112',
            course_catalog: 'C112',
            dept: 'MEC ENG'
          })
        end
      end
      context 'CMS-derived data unavailable' do
        before { %w(catalog_id course_display_name dept_name).each { |key| mec_eng_result.delete key } }
        include_examples 'compensation for bad formatting'
      end
      context 'CMS-derived data partially available' do
        before { %w(catalog_id dept_name).each { |key| mec_eng_result.delete key } }
        include_examples 'compensation for bad formatting'
      end
      context 'CMS-derived data present but compressed' do
        before do
          mec_eng_result['course_display_name'] = 'MECENG C112'
          mec_eng_result['dept_name'] = 'MECENG'
        end
        include_examples 'compensation for bad formatting'
      end
    end

    it 'adds de-duplicated secondaries to the right course' do
      expect(get_sections('MUSIC 74').select { |section| !section[:is_primary_section]}).to have(2).items
    end

    it 'includes course data with instructor-specific properties and without student-specific properties' do
      subject.each do |course|
        expect(course.keys).to include(
          :catid, :course_catalog, :course_code, :dept, :emitter, :enroll_limit, :id, :name, :role,
          :sections, :slug, :term_cd, :term_id, :term_yr, :waitlist_limit
        )
        expect(course[:role]).to eq 'Instructor'
        course[:sections].each do |section|
          expect(section.keys).to include(
            :ccn, :enroll_limit, :instruction_format, :is_primary_section, :section_label,
            :section_number, :waitlist_limit
          )
          expect(section.keys).to include(:units) if section[:is_primary_section]
          expect(section.keys).not_to include(:grading_basis, :waitlistPosition, :waitlisted)
        end
      end
    end

    it 'sums enrollment and waitlist limits for primary sections' do
      expect(get_course('MUSIC 74')[:enroll_limit]).to eq 47
      expect(get_course('MUSIC 74')[:waitlist_limit]).to eq 13
      expect(get_course('MUSIC 99C')[:enroll_limit]).to eq 40
      expect(get_course('MUSIC 99C')[:waitlist_limit]).to eq 10
      expect(get_course('MUSIC C105')[:enroll_limit]).to eq 35
      expect(get_course('MUSIC C105')[:waitlist_limit]).to eq 9
      expect(get_course('MEC ENG C112')[:enroll_limit]).to eq 35
      expect(get_course('MEC ENG C112')[:waitlist_limit]).to eq 9
    end

    it 'assigns cross-listing hashes to matching cs_course_id and section only' do
      expect(get_sections('MUSIC 74').first).not_to include(:cross_listing_hash)
      expect(get_sections('MUSIC 99C').first).not_to include(:cross_listing_hash)
      expect(get_sections('MUSIC C105').first[:cross_listing_hash]).to eq get_sections('MEC ENG C112').first[:cross_listing_hash]
    end

    describe 'canonical course ordering' do
      before { EdoOracle::UserCourses::Base.new(user_id: random_id).sort_courses feed }
      it 'should order courses by code' do
        expect(subject.map { |c| c[:course_code] }).to eq ['MEC ENG C112', 'MUSIC 74', 'MUSIC 99C', 'MUSIC C105']
      end
    end

    describe 'detailed section data merge' do
      let(:instructor_assignments) do
        {
          '44206' => [{uid: '61889', name: 'Majuscule Bear'}],
          '44207' => [{uid: '61889', name: 'Majuscule Bear'}, {uid: '2040', name: 'John Montagu'}],
          '44210' => [{uid: '242881', name: 'Professor Plum'}],
          '44211' => [{uid: '61889', name: 'Majuscule Bear'}],
          '44807' => [{uid: '2040', name: 'John Montagu'}],
          '45807' => [{uid: '2040', name: 'John Montagu'}],
          '54807' => [{uid: '242881', name: 'Professor Plum'}]
        }
      end
      let(:instructor_attributes) do
        [
          {ldap_uid: '61889', first_name: 'minuscule', last_name: 'bear'},
          {ldap_uid: '2040', first_name: 'Earl', last_name: 'of Sandwich'}
        ]
      end
      before do
        instructor_assignments.each do |section_id, instructors|
          allow(EdoOracle::CourseSections).to receive(:new).with('2168', section_id).and_return double(get_section_data: {instructors: instructors})
        end
        expect(User::BasicAttributes).to receive(:attributes_for_uids).with(array_including('2040', '61889', '242881')).and_return instructor_attributes
        EdoOracle::UserCourses::Base.new(user_id: random_id).merge_detailed_section_data feed
      end
      it 'overrides instructor names from directory when available' do
        expect(get_sections('MUSIC 99C').first[:instructors].first[:name]).to eq 'Earl of Sandwich'
        expect(get_sections('MUSIC C105').first[:instructors].first[:name]).to eq 'Earl of Sandwich'
        expect(get_sections('MUSIC 74').first[:instructors].first[:name]).to eq 'minuscule bear'
      end
      it 'uses name from database when no directory entry found' do
        expect(get_sections('MEC ENG C112').first[:instructors].first[:name]).to eq 'Professor Plum'
      end
    end
  end

  describe '#course_ids_from_row' do
    subject { EdoOracle::UserCourses::Base.new(user_id: random_id).course_ids_from_row row }
    shared_examples 'a well-parsed id set' do
      its([:slug]) { should eq 'mec_eng_i_res-0109al' }
      its([:id])  {should eq 'mec_eng_i_res-0109al-2016-D' }
      its([:course_code]) { should eq 'MEC ENG/I,RES 0109AL' }
      its([:dept]) { should eq 'MEC ENG/I,RES' }
      its([:dept_code]) { should eq 'MECENGIRES' }
    end
    let(:subject_areas) { ['MEC ENG/I,RES', 'MUSIC'] }
    context 'dept_name and catalog_id available' do
      let(:row) {{
        'catalog_id' => '0109AL',
        'course_display_name' => 'MEC ENG/I,RES 0109AL',
        'dept_name' => 'MEC ENG/I,RES',
        'dept_code' => 'MECENGIRES',
        'section_display_name' => 'MECENGIRES 0109AL',
        'term_id' => '2168'
      }}
      it_should_behave_like 'a well-parsed id set'
    end
    context 'dept_name and catalog_id unavailable' do
      let(:row) {{
        'catalog_id' => nil,
        'course_display_name' => 'MEC ENG/I,RES 0109AL',
        'dept_name' => nil,
        'dept_code' => 'MECENGIRES',
        'section_display_name' => 'MECENGIRES 0109AL',
        'term_id' => '2168'
      }}
      it_should_behave_like 'a well-parsed id set'
    end
    context 'dept_name, catalog_id and course_display_name unavailable' do
      let(:row) {{
        'catalog_id' => nil,
        'course_display_name' => nil,
        'dept_name' => nil,
        'dept_code' => 'MECENGIRES',
        'section_display_name' => 'MECENGIRES 0109AL',
        'term_id' => '2168'
      }}
      it_should_behave_like 'a well-parsed id set'
    end
    context 'dept_name and course_display_name present but compressed' do
      let(:row) {{
        'catalog_id' => '0109AL',
        'course_display_name' => 'MECENGIRES 0109AL',
        'dept_name' => 'MECENGIRES',
        'dept_code' => 'MECENGIRES',
        'section_display_name' => 'MECENGIRES 0109AL',
        'term_id' => '2168'
      }}
      it_should_behave_like 'a well-parsed id set'
    end
  end

  describe '#row_to_feed_item' do
    let(:row) {{
      'catalog_id' => '0109AL',
      'dept_name' => 'MEC ENG/I,RES',
      'dept_code' => 'MECENGIRES',
      'term_id' => '2168',
      'course_title' => course_title,
      'course_title_short' => 'KOLLAPS',
      'session_id' => session_id
    }}
    let(:course_title) { nil }
    let(:session_id) { '1' }
    subject { EdoOracle::UserCourses::Base.new(user_id: random_id).row_to_feed_item(row, {}) }
    context 'course has a nice long title' do
      let(:course_title) { 'Failure Analysis of Load-Bearing Structures' }
      it 'uses the official title' do
        expect(subject[:name]).to eq course_title
      end
    end
    context 'course has a null COURSE_TITLE column' do
      let(:course_title) { nil }
      it 'falls back to short title' do
        expect(subject[:name]).to eq 'KOLLAPS'
      end
    end
    context 'course has regular academic session id' do
      it 'has nil session code' do
        expect(subject[:session_code]).to eq nil
      end
    end
    context 'course has summer session id' do
      let(:session_id) { '6W2' }
      it 'has converted session code' do
        expect(subject[:session_code]).to eq 'D'
      end
    end
  end

end
