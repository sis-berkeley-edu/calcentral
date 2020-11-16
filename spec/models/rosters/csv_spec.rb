describe Rosters::Csv do

  let(:rosters_feed) do
    {
      campus_course: {id: campus_course_id},
      sections: sections,
      students: students,
    }
  end
  let(:sections) do
    [
      {
        ccn: '24291',
        course_name: 'ECON 100B',
        name: 'ECON 100B LEC 001',
        section_label: primary_section_label,
        section_number: '001',
        instruction_format: 'LEC',
        locations: ['1 Pimentel'],
        dates: ['MWF 4:00P-4:59P'],
        cross_listing: true,
        is_primary: true,
      },
      {
        ccn: '22050',
        course_name: 'MATH 100B',
        name: 'MATH 100B LEC 001',
        section_label: primary_section_label,
        section_number: '001',
        instruction_format: 'LEC',
        locations: ['1 Pimentel'],
        dates: ['MWF 4:00P-4:59P'],
        cross_listing: true,
        is_primary: true,
      },
      {
        ccn: '24292',
        course_name: 'ECON 100B',
        name: 'ECON 100B DIS 110',
        section_label: 'DIS 110',
        section_number: '110',
        instruction_format: 'DIS',
        locations: ['289 Cory'],
        dates: ['MW 5:00P-5:59P'],
        cross_listing: true,
        is_primary: false,
      },
      {
        ccn: '26893',
        course_name: 'MATH 100B',
        name: 'MATH 100B DIS 115',
        section_label: 'DIS 115',
        section_number: '115',
        instruction_format: 'DIS',
        locations: ['B56 Hildebrand'],
        dates: ['TuTh 3:00P-3:59P'],
        cross_listing: true,
        is_primary: false,
      },
    ]
  end
  let(:students) do
    [
      {
        id: '1000123',
        login_id: '1000123',
        student_id: '12345',
        first_name: 'Hartmut',
        last_name: 'Dragica',
        email: 'hdragica@example.com',
        enroll_status: 'E',
        majors: ["Break Science BA"],
        terms_in_attendance: '5',
        academic_career: 'UGRD',
        section_ccns: ['22050', '22060'],
        grade_option: 'Letter',
        units: '4.0',
        profile_url: 'http://example.com/directory/results?search-type=uid&search-base=all&search-term=1000123',
        sections: [
          {
            ccn: '24291',
            course_name: 'ECON 100B',
            name: 'ECON 100B LEC 001',
            section_label: primary_section_label,
            section_number: '001',
            instruction_format: 'LEC',
            locations: ['1 Pimentel'],
            dates: ['MWF 4:00P-4:59P'],
            cross_listing: true,
            is_primary: true,
          },
          {
            ccn: '24292',
            course_name: 'ECON 100B',
            name: 'ECON 100B DIS 110',
            section_label: 'DIS 110',
            section_number: '110',
            instruction_format: 'DIS',
            locations: ['289 Cory'],
            dates: ['MW 5:00P-5:59P'],
            cross_listing: true,
            is_primary: false,
          },
        ],
        columns: [
          {
            instruction_format: 'LEC',
            primary_group_key: :primary,
            section_number: '001'
          },
          {
            instruction_format: 'DIS',
            primary_group_key: :secondary,
            section_number: '110'
          },
        ],
        photo: '/campus/econ-100b-2019-B/photo/1000123',
      },
      {
        id: '1000124',
        login_id: '1000124',
        student_id: '12346',
        first_name: 'Borislav',
        last_name: 'Yuri',
        email: 'byuri@example.com',
        enroll_status: 'W',
        majors: ['Political Economy BA', 'Computer Science BA'],
        terms_in_attendance: '7',
        academic_career: 'UGRD',
        section_ccns: ['22050', '26893'],
        grade_option: 'Letter',
        units: '3.7',
        profile_url: 'http://example.com/directory/results?search-type=uid&search-base=all&search-term=1000124',
        sections: [
          {
            ccn: '22050',
            course_name: 'MATH 100B',
            name: 'MATH 100B LEC 001',
            section_label: primary_section_label,
            section_number: '001',
            instruction_format: 'LEC',
            locations: ['1 Pimentel'],
            dates: ['MWF 4:00P-4:59P'],
            cross_listing: true,
            is_primary: true,
          },
          {
            ccn: '26893',
            course_name: 'MATH 100B',
            name: 'MATH 100B DIS 115',
            section_label: 'DIS 115',
            section_number: '115',
            instruction_format: 'DIS',
            locations: ['B56 Hildebrand'],
            dates: ['TuTh 3:00P-3:59P'],
            cross_listing: true,
            is_primary: false,
          },
        ],
        columns: [
          {
            instruction_format: 'LEC',
            primary_group_key: :primary,
            section_number: '001'
          },
          {
            instruction_format: 'DIS',
            primary_group_key: :secondary,
            section_number: '115'
          },
        ],
        photo: '/campus/econ-100b-2019-B/photo/1000124',
      }
    ]
  end
  let(:primary_section_label) { 'LEC 001' }
  let(:campus_course_id) { 'econ-100b-2019-B' }
  let(:section_id) { nil }
  let(:enroll_option) { 'all' }
  let(:options) do
    {
      campus_course_id: campus_course_id,
      section_id: section_id,
      enroll_option: enroll_option,
    }
  end
  subject { Rosters::Csv.new(rosters_feed, options) }

  describe '#get_filename' do
    let(:filename) { subject.get_filename }
    context 'when section id is present' do
      let(:section_id) { '22050' }
      it 'returns filename with section label' do
        expect(filename).to eq 'econ-100b-2019-B_LEC-001_rosters.csv'
      end
      context 'when section label contains multiple spaces' do
        let(:primary_section_label) { 'LEC   001' }
        it 'returns filename with underscores in section label' do
          expect(filename).to eq 'econ-100b-2019-B_LEC-001_rosters.csv'
        end
      end
    end

    context 'when section id is not present' do
      let(:section_id) { nil }
      it 'returns filename without section label' do
        expect(filename).to eq 'econ-100b-2019-B_rosters.csv'
      end
    end
    context 'when enroll option is present' do
      let(:section_id) { '24291' }
      let(:enroll_option) { 'waitlisted' }
      it 'returns filename with enroll type' do
        expect(filename).to eq 'econ-100b-2019-B_LEC-001_waitlisted_rosters.csv'
      end
    end
    context 'when enroll option is not present' do
      let(:enroll_option) { nil }
      it 'returns filename with enroll type' do
        expect(filename).to eq 'econ-100b-2019-B_rosters.csv'
      end
    end
  end

  describe '#get_csv' do
    it 'returns rosters csv' do
      rosters_csv_string = subject.get_csv
      expect(rosters_csv_string).to be_an_instance_of String
      rosters_csv = CSV.parse(rosters_csv_string, {headers: true})
      expect(rosters_csv.count).to eq 2
      expect(rosters_csv.headers()).to include('Name', 'User ID', 'Student ID', 'Email Address', 'Role', 'Course', 'LEC', 'DIS')
      expect(rosters_csv.headers()).to include('Majors', 'Terms in Attendance', 'Units', 'Grading Basis', 'Waitlist Position')

      expect(rosters_csv[0]).to be_an_instance_of CSV::Row
      expect(rosters_csv[0]['Name']).to eq 'Dragica, Hartmut'
      expect(rosters_csv[0]['User ID']).to eq '1000123'
      expect(rosters_csv[0]['Student ID']).to eq '12345'
      expect(rosters_csv[0]['Email Address']).to eq 'hdragica@example.com'
      expect(rosters_csv[0]['Role']).to eq 'Student'
      expect(rosters_csv[0]['Course']).to eq 'ECON 100B'
      expect(rosters_csv[0]['LEC']).to eq '001'
      expect(rosters_csv[0]['DIS']).to eq '110'
      expect(rosters_csv[0]['Majors']).to eq 'Break Science BA'
      expect(rosters_csv[0]['Terms in Attendance']).to eq '5'
      expect(rosters_csv[0]['Units']).to eq '4.0'
      expect(rosters_csv[0]['Grading Basis']).to eq 'Letter'
      expect(rosters_csv[0]['Waitlist Position']).to eq ''

      expect(rosters_csv[1]).to be_an_instance_of CSV::Row
      expect(rosters_csv[1]['Name']).to eq 'Yuri, Borislav'
      expect(rosters_csv[1]['User ID']).to eq '1000124'
      expect(rosters_csv[1]['Student ID']).to eq '12346'
      expect(rosters_csv[1]['Email Address']).to eq 'byuri@example.com'
      expect(rosters_csv[1]['Role']).to eq 'Waitlist Student'
      expect(rosters_csv[1]['Course']).to eq 'MATH 100B'
      expect(rosters_csv[1]['LEC']).to eq '001'
      expect(rosters_csv[1]['DIS']).to eq '115'
      expect(rosters_csv[1]['Majors']).to eq 'Computer Science BA, Political Economy BA'
      expect(rosters_csv[1]['Terms in Attendance']).to eq '7'
      expect(rosters_csv[1]['Units']).to eq '3.7'
      expect(rosters_csv[1]['Grading Basis']).to eq 'Letter'
      expect(rosters_csv[1]['Waitlist Position']).to eq ''
    end
  end

  describe '#filter_students_by_section_id' do
    let(:section_id) { '16' }
    let(:students) do
      [
        {student_id: '12345', section_ccns: ['14', '15']},
        {student_id: '12346', section_ccns: ['14', '16']},
        {student_id: '12347', section_ccns: ['14', '17']},
        {student_id: '12348', section_ccns: ['14', '18']},
        {student_id: '12349', section_ccns: ['14', '16']},
      ]
    end
    before { subject.filter_students_by_section_id(students, section_id) }
    context 'when students array is empty' do
      let(:students) { [] }
      it 'does nothing' do
        expect(students).to eq []
      end
    end
    context 'when section id is blank' do
      let(:section_id) { nil }
      it 'does nothing' do
        expect(students.count).to eq 5
      end
    end
    it 'filters student collection by provided section id' do
      expect(students.count).to eq 2
      expect(students[0][:student_id]).to eq '12346'
      expect(students[1][:student_id]).to eq '12349'
    end
  end

  describe '#filter_students_by_enroll_option' do
    let(:students) do
      [
        {student_id: '12345', enroll_status: 'W'},
        {student_id: '12346', enroll_status: 'E'},
        {student_id: '12347', enroll_status: 'E'},
        {student_id: '12348', enroll_status: 'W'},
        {student_id: '12349', enroll_status: 'E'},
      ]
    end
    let(:enroll_status) { 'enrolled' }
    before { subject.filter_students_by_enroll_option(students, enroll_status) }
    context 'when students array is empty' do
      let(:students) { [] }
      it 'does nothing' do
        expect(students).to eq []
      end
    end
    context 'when enroll status is \'waitlisted\'' do
      let(:enroll_status) { 'waitlisted' }
      it 'does nothing' do
        expect(students.count).to eq 2
        expect(students[0][:student_id]).to eq '12345'
        expect(students[1][:student_id]).to eq '12348'
      end
    end
    context 'when enroll status is blank' do
      let(:enroll_status) { nil }
      it 'does nothing' do
        expect(students.count).to eq 5
      end
    end
    context 'when enroll status is \'all\'' do
      let(:enroll_status) { 'all' }
      it 'returns all students unfiltered' do
        expect(students.count).to eq 5
      end
    end
    it 'filters student collection by provided enrollment option' do
      subject.filter_students_by_enroll_option(students, 'enrolled')
      expect(students.count).to eq 3
      expect(students[0][:student_id]).to eq '12346'
      expect(students[1][:student_id]).to eq '12347'
      expect(students[2][:student_id]).to eq '12349'
    end
  end

end
