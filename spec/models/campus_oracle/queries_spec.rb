describe CampusOracle::Queries do
  let(:current_term) {Berkeley::Terms.fetch.current}

  it_behaves_like 'an Oracle driven data source' do
    subject { CampusOracle::Queries }
  end

  describe '.stringify_column!' do
    context 'when column is course control number' do
      it 'converts to 5 digit string with zero padding' do
        row_hash = {'course_cntl_num' => 123}
        CampusOracle::Queries.stringify_column!(row_hash, 'course_cntl_num')
        expect(row_hash['course_cntl_num']).to eq '00123'
      end
    end
  end

  it 'provides settings' do
    expect(CampusOracle::Queries.settings).to be Settings.campusdb
  end

  it 'should find some students in Biology 1a' do
    students = CampusOracle::Queries.get_enrolled_students('7309', '2013', 'D')
    expect(students).to_not be_nil
    expect(students).to be_an_instance_of Array
    if CampusOracle::Queries.test_data?
      # we will only have predictable enrollments in our fake Oracle db.
      expect(students).to have(1).items
      expect(students[0]['ldap_uid']).to eq '300939'
      expect(students[0]['enroll_status']).to eq 'E'
      expect(students[0]['pnp_flag']).to eq 'N'
      expect(students[0]['first_name']).to eq 'STUDENT'
      expect(students[0]['last_name']).to eq 'TEST-300939'
      expect(students[0]['student_email_address']).to eq 'test-300939@berkeley.edu'
      expect(students[0]['student_id']).to eq '22300939'
      expect(students[0]['affiliations']).to eq 'STUDENT-TYPE-REGISTERED'
    end
    students.each do |student_row|
      expect(student_row['enroll_status']).to_not be_blank
      expect(student_row['student_id']).to_not be_blank
    end
  end

  it 'should find some enrollments in multiple sections' do
    enrollments = CampusOracle::Queries.get_enrolled_students_for_ccns(%w(7309 7366 16171), '2013', 'D')
    if CampusOracle::Queries.test_data?
      # we will only have predictable enrollments in our fake Oracle db.
      expect(enrollments).to have(3).items
      expect(enrollments[0]['ldap_uid']).to eq '300939'
      expect(enrollments[0]['course_cntl_num']).to eq '07309'
      expect(enrollments[0]['enroll_status']).to eq 'E'
      expect(enrollments[0]['pnp_flag']).to eq 'N'
      expect(enrollments[0]['first_name']).to eq 'STUDENT'
      expect(enrollments[0]['last_name']).to eq 'TEST-300939'
      expect(enrollments[0]['student_email_address']).to eq 'test-300939@berkeley.edu'
      expect(enrollments[0]['student_id']).to eq '22300939'
      expect(enrollments[0]['affiliations']).to eq 'STUDENT-TYPE-REGISTERED'
      expect(enrollments[1]['ldap_uid']).to eq '300939'
      expect(enrollments[1]['course_cntl_num']).to eq '07366'
      expect(enrollments[2]['ldap_uid']).to eq '300939'
      expect(enrollments[2]['course_cntl_num']).to eq '16171'
    end
    enrollments.each do |enrollment_row|
      expect(enrollment_row['enroll_status']).to be_present
      expect(enrollment_row['student_id']).to be_present
    end
  end

  it 'should find sections from CCNs' do
    courses = CampusOracle::Queries.get_sections_from_ccns('2013', 'D', %w(7309 07366 919191 16171))
    expect(courses).to_not be_nil
    if CampusOracle::Queries.test_data?
      courses.length.should == 3
      index = courses.index { |c|
        c['dept_name'] == 'BIOLOGY' &&
          c['catalog_id'] == '1A' &&
          c['course_title'] == 'General Biology Lecture' &&
          c['course_title_short'] == 'GENERAL BIOLOGY LEC' &&
          c['primary_secondary_cd'] == 'P' &&
          c['instruction_format'] == 'LEC' &&
          c['section_num'] == '003'
      }
      expect(index).to_not be_nil
    end
  end

  context 'confined to current term' do
    it 'should be able to limit enrollment queries' do
      sections = CampusOracle::Queries.get_enrolled_sections('300939', [current_term])
      expect(sections).to_not be_nil
      expect(sections).to have(3).items if CampusOracle::Queries.test_data?
    end
    it 'should be able to limit teaching assignment queries' do
      # These are only the explicitly assigned sections and do not include implicit nesting.
      sections = CampusOracle::Queries.get_instructing_sections('238382', [current_term])
      expect(sections).to_not be_nil
      expect(sections).to have(2).items if CampusOracle::Queries.test_data?
    end
  end

  context '#get_enrolled_sections', if: CampusOracle::Connection.test_data? do
    subject { CampusOracle::Queries.get_enrolled_sections('300939') }
    it 'should include requested columns' do
      expect(subject).to be_present
      %w(dept_description term_yr term_cd course_cntl_num enroll_status wait_list_seq_num unit pnp_flag grade
        catalog_root catalog_prefix catalog_suffix_1 catalog_suffix_2 enroll_limit cred_cd course_option).each do |column|
        expect(subject).to all(include column)
      end
    end
  end

  it 'finds cross-listed course data', if: CampusOracle::Connection.test_data? do
    cross_listing_hash = CampusOracle::Queries.get_cross_listings(2013, 'D', %w(7853 7856 7859 83212 83214 83485))
    expect(cross_listing_hash.size).to eq 2
    expect(cross_listing_hash[7853]).to be_present
    expect(cross_listing_hash[7853]).to eq cross_listing_hash[83212]
  end

  it 'should find where a person is teaching' do
    sections = CampusOracle::Queries.get_instructing_sections('238382')
    expect(sections).to_not be_nil
    expect(sections).to have(4).items if CampusOracle::Queries.test_data?
  end

  it 'finds all active sections for the course' do
    sections = CampusOracle::Queries.get_all_course_sections(2013, 'D', 'BIOLOGY', '1A')
    # This is a real course offering and should show up in live DBs.
    expect(sections).to_not be_nil
    if CampusOracle::Queries.test_data?
      expect(sections).to have(3).items
      # Should not include canceled section.
      expect(sections.select{|s| s['course_cntl_num'].to_i == 7309}).to_not be_empty
    end
  end

  it 'finds all active secondary sections for the course' do
    sections = CampusOracle::Queries.get_course_secondary_sections(2013, 'D', 'BIOLOGY', '1A')
    # This is a real course offering and should show up in live DBs.
    expect(sections).to_not be_nil
    if CampusOracle::Queries.test_data?
      expect(sections).to have(2).items
      # Should not include canceled section.
      expect(sections.select{|s| s['course_cntl_num'].to_i == 7309}).to be_empty
    end
  end

  it 'should check whether the db is alive' do
    alive = CampusOracle::Queries.database_alive?
    expect(alive).to be true
  end

  it 'should report DB outage' do
    CampusOracle::Queries.connection.stub(:select_one).and_raise(
      ActiveRecord::StatementInvalid,
      'Java::JavaSql::SQLRecoverableException: IO Error: The Network Adapter could not establish the connection: select 1 from DUAL'
    )
    is_ok = CampusOracle::Queries.database_alive?
    expect(is_ok).to be false
  end

  it 'should return class schedule data' do
    data = CampusOracle::Queries.get_section_schedules('2013', 'D', '16171')
    expect(data).to_not be_nil
    if CampusOracle::Queries.test_data?
      expect(data).to have(2).items
      expect(data[0]['building_name']).to eq 'WHEELER'
      expect(data[1]['building_name']).to eq 'DWINELLE'
    end
  end

  it 'should respect business rule about print_cd of A in class schedule data' do
    data = CampusOracle::Queries.get_section_schedules('2013', 'D', '12345')
    expect(data).to_not be_nil
    expect(data).to have(1).items if CampusOracle::Queries.test_data?
  end

  it 'should return instructor data given a course control number' do
    data = CampusOracle::Queries.get_section_instructors('2013', 'D', '7309')
    expect(data).to_not be_nil
    if CampusOracle::Queries.test_data?
      expect(data[0]['ldap_uid']).to eq '238382'
      expect(data[0]['student_id']).to eq '238382' # student id is typically nil for instructors
      expect(data[0]['first_name']).to eq 'BERNADETTE ANNE'
      expect(data[0]['last_name']).to eq 'GEUY'
      expect(data[0]['person_name']).to eq 'GEUY,BERNADETTE ANNE'
      expect(data[0]['email_address']).to eq '238382@example.edu'
      expect(data[0]['affiliations']).to eq 'EMPLOYEE-TYPE-STAFF,STUDENT-STATUS-EXPIRED'

      expect(data[1]['person_name']).to eq 'Chris Tweney'
      expect(data[1]['instructor_func']).to eq '4'
    end
  end

  it 'should be able to get a whole lot of user records' do
    known_uids = %w(238382 2040 3060 211159 238382)
    lotsa_uids = Array.new(1000 - known_uids.length) {|i| i + 1 }
    lotsa_uids.concat known_uids
    user_data = CampusOracle::Queries.get_basic_people_attributes lotsa_uids
    user_data.each do |row|
      known_uids.delete row['ldap_uid']
    end
    expect(known_uids).to be_empty
  end

  it 'should be able to get all active user uids' do
    if CampusOracle::Queries.test_data?
      uids = CampusOracle::Queries.get_all_active_people_uids
      expect(uids).to have(146).items
      expect(uids).to include('212373')
      expect(uids).to include('95509')
      expect(uids).to_not include('592722')
      expect(uids).to_not include('313561')
      expect(uids).to_not include('6188989')
    end
  end

  it 'should be able to look up Tammi student info' do
    info = CampusOracle::Queries.get_student_info '300939'
    expect(info).to_not be_nil
    if CampusOracle::Queries.test_data?
      expect(info['first_reg_term_cd']).to eq 'D'
      expect(info['first_reg_term_yr']).to eq '2013'
    end
  end

  it 'should find a user with an expired LDAP account', if: CampusOracle::Queries.test_data? do
    expect(CampusOracle::Queries.get_basic_people_attributes(['6188989']).first['person_type']).to eq 'Z'
  end

  context 'with default academic terms', if: CampusOracle::Queries.test_data? do
    let(:academic_terms) {Berkeley::Terms.fetch.campus.values}
    it 'should say an instructor has instructional history' do
      expect(CampusOracle::Queries.has_instructor_history?('238382', academic_terms)).to be true
    end
    it 'should say a student has student history' do
      expect(CampusOracle::Queries.has_student_history?('300939', academic_terms)).to be true
    end
    it 'should say a staff member does not have instructional or student history' do
      expect(CampusOracle::Queries.has_instructor_history?('2040', academic_terms)).to be false
      expect(CampusOracle::Queries.has_student_history?('2040', academic_terms)).to be false
    end
  end

  context 'when searching for users by name' do
    it 'should raise exception if search string argument is not a string' do
      expect { CampusOracle::Queries.find_people_by_name(12345) }.to raise_error(ArgumentError, 'Search text argument must be a string')
    end

    it 'should raise exception if row limit argument is not an integer' do
      expect { CampusOracle::Queries.find_people_by_name('TEST-', '15') }.to raise_error(ArgumentError, 'Limit argument must be a Fixnum')
    end

    it 'should escape user input to avoid SQL injection' do
      allow(CampusOracle::Queries.connection).to receive(:select_all).and_return(nil)
      CampusOracle::Queries.connection.should_receive(:quote_string).with("anything' OR 'x'='x").and_return("anything'' OR ''x''=''x")
      user_data = CampusOracle::Queries.find_people_by_name("anything' OR 'x'='x")
    end
  end

  context 'when searching for users by email' do
    it 'should raise exception if search string argument is not a string' do
      expect { CampusOracle::Queries.find_people_by_email(12345) }.to raise_error(ArgumentError, 'Search text argument must be a string')
    end

    it 'should raise exception if row limit argument is not an integer' do
      expect { CampusOracle::Queries.find_people_by_email('test-', '15') }.to raise_error(ArgumentError, 'Limit argument must be a Fixnum')
    end
  end

  context 'when searching for active user by LDAP user id' do
    it 'should find active user by exact LDAP user ID', if: CampusOracle::Queries.test_data? do
      user_data = CampusOracle::Queries.find_active_uid('300847')
      expect(user_data).to be_an_instance_of Array
      expect(user_data).to have(1).items
      expect(user_data[0]).to be_an_instance_of Hash
      expect(user_data[0]['first_name']).to eq 'STUDENT'
      expect(user_data[0]['last_name']).to eq 'TEST-300847'
    end

    it 'should not find an expired account', if: CampusOracle::Queries.test_data? do
      user_data = CampusOracle::Queries.find_active_uid('6188989')
      expect(user_data).to have(0).items
    end

    it 'should not find a user without active affiliations', if: CampusOracle::Queries.test_data? do
      user_data = CampusOracle::Queries.find_active_uid('300906')
      expect(user_data).to have(0).items
    end
  end

  context 'when checking integer format of string' do
    it 'raises exception if argument is not a string' do
      expect { CampusOracle::Queries.is_integer_string?(188902) }.to raise_error(ArgumentError, 'Argument must be a string')
    end

    it 'returns true if string is successfully converted to an integer' do
      expect(CampusOracle::Queries.is_integer_string?('189023')).to be_truthy
    end

    it 'returns false if string is not successfully converted to an integer' do
      expect(CampusOracle::Queries.is_integer_string?('18dfsd9023')).to be false
      expect(CampusOracle::Queries.is_integer_string?('254AbCdE')).to be false
      expect(CampusOracle::Queries.is_integer_string?('98,()@')).to be false
      expect(CampusOracle::Queries.is_integer_string?('2390.023')).to be false
    end
  end

end
