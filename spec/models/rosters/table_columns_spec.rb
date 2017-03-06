describe Rosters::TableColumns do
  let(:lec_section1) do
    {
      :name=>"COMPSCI 849 LEC 001",
      :instruction_format => 'LEC',
      :is_primary => true,
      :section_number => '001'
    }
  end
  let(:lec_section2) do
    {
      :name=>"COMPSCI 849 LEC 002",
      :instruction_format => 'LEC',
      :is_primary => true,
      :section_number => '002'
    }
  end
  let(:lec_section3) do
    {
      :name=>"COMPSCI 849 LEC 401",
      :instruction_format => 'LEC',
      :is_primary => false,
      :section_number => '401'
    }
  end
  let(:lab_section1) do
    {
      :name=>"COMPSCI 849 LAB 101",
      :instruction_format => 'LAB',
      :is_primary => false,
      :section_number => '101'
    }
  end
  let(:lab_section2) do
    {
      :name=>"COMPSCI 849 LAB 102",
      :instruction_format => 'LAB',
      :is_primary => false,
      :section_number => '102'
    }
  end
  let(:dis_section1) do
    {
      :name=>"COMPSCI 849 DIS 201",
      :instruction_format => 'DIS',
      :is_primary => false,
      :section_number => '001',
    }
  end
  let(:dis_section2) do
    {
      :name=>"COMPSCI 849 DIS 202",
      :instruction_format => 'DIS',
      :is_primary => false,
      :section_number => '002'
    }
  end
  let(:student1) { {:student_id => '10001', :sections => [lec_section1, lab_section1]} }
  let(:student2) { {:student_id => '10002', :sections => [lec_section2, lab_section2, dis_section2]} }
  let(:student3) { {:student_id => '10003', :sections => [lab_section2, lec_section1, dis_section2, lec_section2, lab_section1, lec_section3]} }
  let(:student4) { {:student_id => '10004', :sections => [dis_section2, lab_section2, lab_section1]} }
  let(:students) { [student1, student2, student3, student4] }

  let(:section_headers_prototype) do
    [
      {:instruction_format => 'LEC', :primary_group_key => :primary, :columns => 2},
      {:instruction_format => 'DIS', :primary_group_key => :secondary, :columns => 1},
      {:instruction_format => 'LAB', :primary_group_key => :secondary, :columns => 2},
      {:instruction_format => 'LEC', :primary_group_key => :secondary, :columns => 1}
    ]
  end
  let(:students_columns_hash) do
    {
      student3[:student_id]=>{
        :secondary=>{
          "LAB"=>[
            {:instruction_format=>"LAB", :is_primary=>false, :section_number=>"201"}
          ],
          "DIS"=>[{:instruction_format=>"DIS", :is_primary=>false, :section_number=>"102"}],
          "LEC"=>[
            {:instruction_format=>"LEC", :is_primary=>false, :section_number=>"401"}
          ]
        },
        :primary=>{
          "LEC"=>[
            {:instruction_format=>"LEC", :is_primary=>true, :section_number=>"002"},
            {:instruction_format=>"LEC", :is_primary=>true, :section_number=>"001"}
          ]
        }
      },
      student4[:student_id]=>{
        :secondary=>{
          "DIS"=>[{:instruction_format=>"DIS", :is_primary=>false, :section_number=>"101"}],
          "LAB"=>[
            {:instruction_format=>"LAB", :is_primary=>false, :section_number=>"202"},
            {:instruction_format=>"LAB", :is_primary=>false, :section_number=>"201"}
          ]
        }
      }
    }
  end

  describe '#get_students_with_columns_and_headers' do
    let(:section_columns_and_headers) { subject.get_students_with_columns_and_headers(students) }
    it 'returns students with columns and headers' do
      expect(section_columns_and_headers[:headers].count).to eq 6
      expect(section_columns_and_headers[:students].count).to eq 4
      section_columns_and_headers[:students].each do |student|
        expect(student[:columns].count).to eq 6
      end
    end
  end

  describe '#get_student_section_columns' do
    let(:student_section_columns) { subject.get_student_section_columns(students) }
    it 'returns student section columns and headers with same column count' do
      expect(student_section_columns[:headers].count).to eq 6
      expect(student_section_columns[:student_columns].count).to eq 4
      student_section_columns[:student_columns].each do |student_id, columns|
        expect(columns.count).to eq student_section_columns[:headers].count
      end
    end
  end

  describe '#get_student_columns' do
    let(:student_columns) { subject.get_student_columns(section_headers_prototype, students_columns_hash) }
    it 'returns student section columns based on header prototype' do
      expect(student_columns.keys.count).to eq 2
      student_ids = student_columns.keys
      student1_section_numbers = student_columns[student_ids[0]].collect {|col| col[:section_number]}
      student2_section_numbers = student_columns[student_ids[1]].collect {|col| col[:section_number]}
      expect(student1_section_numbers).to eq ['001', '002', '102', '201', nil, '401']
      expect(student2_section_numbers).to eq [nil, nil, '101', '201', '202', nil]
    end
  end

  describe '#get_section_headers' do
    let(:section_headers) { subject.get_section_headers(section_headers_prototype) }
    it 'returns section headers array' do
      expect(section_headers.count).to eq 6
      expect(section_headers[0][:instruction_format]).to eq 'LEC'
      expect(section_headers[0][:primary_group_key]).to eq :primary
      expect(section_headers[1][:instruction_format]).to eq 'LEC'
      expect(section_headers[1][:primary_group_key]).to eq :primary
      expect(section_headers[2][:instruction_format]).to eq 'DIS'
      expect(section_headers[2][:primary_group_key]).to eq :secondary
      expect(section_headers[3][:instruction_format]).to eq 'LAB'
      expect(section_headers[3][:primary_group_key]).to eq :secondary
      expect(section_headers[4][:instruction_format]).to eq 'LAB'
      expect(section_headers[4][:primary_group_key]).to eq :secondary
      expect(section_headers[5][:instruction_format]).to eq 'LEC'
      expect(section_headers[5][:primary_group_key]).to eq :secondary
    end
  end

  describe '#get_section_headers_prototype' do
    let(:section_headers_prototype) { subject.get_section_headers_prototype(students_columns_hash) }
    it 'returns section headers prototype' do
      expect(section_headers_prototype.count).to eq 4
      expect(section_headers_prototype[0][:instruction_format]).to eq 'LEC'
      expect(section_headers_prototype[0][:primary_group_key]).to eq :primary
      expect(section_headers_prototype[0][:columns]).to eq 2
      expect(section_headers_prototype[1][:instruction_format]).to eq 'DIS'
      expect(section_headers_prototype[1][:primary_group_key]).to eq :secondary
      expect(section_headers_prototype[1][:columns]).to eq 1
      expect(section_headers_prototype[2][:instruction_format]).to eq 'LAB'
      expect(section_headers_prototype[2][:primary_group_key]).to eq :secondary
      expect(section_headers_prototype[2][:columns]).to eq 2
      expect(section_headers_prototype[3][:instruction_format]).to eq 'LEC'
      expect(section_headers_prototype[3][:primary_group_key]).to eq :secondary
      expect(section_headers_prototype[3][:columns]).to eq 1
    end
  end

  describe '#get_student_section_columns_hash' do
    let(:students) { [student3, student4] }
    it 'returns hash with students by sid' do
      student_columns = subject.get_student_section_columns_hash(students)
      expect(student_columns[students[0][:student_id]]).to be_an_instance_of Hash
      expect(student_columns[students[1][:student_id]]).to be_an_instance_of Hash
    end
  end

  describe '#section_columns_hash' do
    let(:student_sections) { student3[:sections] }
    let(:columns_hash) { subject.section_columns_hash(student_sections) }
    it 'converts sections into section columns hash' do
      unwanted_keys = [:name, :section_label, :dates, :locations, :enroll_limit, :enroll_count, :enroll_open, :waitlist_limit, :waitlist_count, :waitlist_open]
      expect(columns_hash[:primary].keys).to eq ['LEC']
      expect(columns_hash[:secondary].keys.sort).to eq ['DIS', 'LAB', 'LEC']
      expect(columns_hash[:primary]['DIS']).to_not be
      expect(columns_hash[:primary]['LAB']).to_not be
      expect(columns_hash[:primary]['LEC'].count).to eq 2
      expect(columns_hash[:primary]['LEC'][0][:is_primary]).to eq true
      expect(columns_hash[:secondary]['DIS'].count).to eq 1
      expect(columns_hash[:secondary]['LAB'].count).to eq 2
      expect(columns_hash[:secondary]['LEC'].count).to eq 1
      expect(columns_hash[:secondary]['LEC'][0][:is_primary]).to eq false
      columns_hash.values.each do |primary_hash|
        primary_hash.values.each do |instruction_format_section_set|
          instruction_format_section_set.each do |section|
            expect(section).to have_key(:instruction_format)
            expect(section).to have_key(:is_primary)
            expect(section).to have_key(:section_number)
            expect(section).to_not have_keys(unwanted_keys)
          end
        end
      end
    end
  end

end
