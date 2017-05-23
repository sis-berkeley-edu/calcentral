describe Oec::DepartmentMappings, if: in_memory_database? do

  let(:term_id) {'2172'}
  let(:term_code) {'2017-B'}
  let(:include_fssem) {false}
  before do
    Oec::CourseCode.create(dept_name: 'A,RESEC', catalog_id: '', dept_code: 'MBARC', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'BIOLOGY', catalog_id: '1A', dept_code: 'IMMCB', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'BIOLOGY', catalog_id: '1AL', dept_code: 'IMMCB', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'BIOLOGY', catalog_id: '1B', dept_code: 'IBIBI', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'BIOLOGY', catalog_id: '1BL', dept_code: 'IBIBI', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'CATALAN', catalog_id: '', dept_code: 'LPSPP', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'CHEM', catalog_id: '', dept_code: 'CCHEM', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'CHEM', catalog_id: '54GET', dept_code: 'UNFRNDLY', include_in_oec: false)
    Oec::CourseCode.create(dept_name: 'CLASSIC', catalog_id: '', dept_code: 'LSCLA', include_in_oec: false)
    Oec::CourseCode.create(dept_name: 'INTEGBI', catalog_id: '', dept_code: 'IBIBI', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'MCELLBI', catalog_id: '', dept_code: 'IMMCB', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'PORTUG', catalog_id: '', dept_code: 'LPSPP', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'PORTUG', catalog_id: '86EXCLUDE', dept_code: 'LPSPP', include_in_oec: false)
    Oec::CourseCode.create(dept_name: 'PORTUG', catalog_id: '66OTHER', dept_code: 'MBARC', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'SPANISH', catalog_id: '', dept_code: 'LPSPP', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'FSSEM', catalog_id: '', dept_code: 'FSSEM', include_in_oec: include_fssem)
    allow(EdoOracle::Oec).to receive(:get_fssem_course_codes).with(term_id).and_return([
      {dept_name: 'CHEM', catalog_id: '24'},
      {dept_name: 'CLASSIC', catalog_id: '24'},
      {dept_name: 'CLASSIC', catalog_id: '39D'},
      {dept_name: 'MCELLBI', catalog_id: '90A'},
      {dept_name: 'MCELLBI', catalog_id: '90B'},
      {dept_name: 'PORTUG', catalog_id: '24'}
    ])
  end

  subject { Oec::DepartmentMappings.new(term_code: term_code) }

  describe '#by_dept_code' do
    # Options are a choice of {dept_code: [dept_codes...]} or {include_in_oec: true}
    let(:mappings) { subject.by_dept_code(opts) }
    shared_examples 'a dept_code mapping' do
      it 'includes LPSPP rows' do
        expect(mappings.keys).to include 'LPSPP'
        matching_array = mappings['LPSPP'].map {|code_row| code_row.to_h}
        expect(matching_array.length).to eq 4
        expect(matching_array).to include(
          {dept_name: 'CATALAN', catalog_id: '', dept_code: 'LPSPP', include_in_oec: true},
          {dept_name: 'PORTUG', catalog_id: '', dept_code: 'LPSPP', include_in_oec: true},
          {dept_name: 'PORTUG', catalog_id: '86EXCLUDE', dept_code: 'LPSPP', include_in_oec: false},
          {dept_name: 'SPANISH', catalog_id: '', dept_code: 'LPSPP', include_in_oec: true}
        )
      end
    end
    context 'single department' do
      let(:opts) { {dept_code: ['LPSPP']} }
      it_behaves_like 'a dept_code mapping'
      it 'only has one dept_code' do
        expect(mappings.keys).to eq ['LPSPP']
      end
    end
    context 'multiple departments' do
      let(:opts) { {dept_code: ['CCHEM', 'LPSPP', 'NONESUCH', 'UNFRNDLY']} }
      it_behaves_like 'a dept_code mapping'
      it 'maps all found dept_codes' do
        expect(mappings.keys).to include('CCHEM', 'LPSPP', 'UNFRNDLY')
        expect(mappings['CCHEM'].length).to eq 1
        expect(mappings['UNFRNDLY'].length).to eq 1
      end
    end
    context 'all included departments' do
      let(:opts) { {include_in_oec: true} }
      it 'includes all enabled dept_codes' do
        expect(mappings.keys).to include('CCHEM', 'IBIBI', 'IMMCB', 'LPSPP', 'MBARC')
        expect(mappings.keys).not_to include('LSCLA')
        expect(mappings.keys).not_to include('FSSEM')
        matching_array = mappings['LPSPP'].map {|code_row| code_row.to_h}
        expect(matching_array.length).to eq 3
        expect(matching_array.find {|c| c[:dept_name] == 'PORTUG' && c[:catalog_id] == '86EXCLUDE'}).to be_nil
      end
      context 'with FSSem' do
        let(:include_fssem) {true}
        it 'includes FSSem-administered courses' do
          expect(mappings.keys).not_to include('LSCLA')
          matching_array = mappings['FSSEM'].map {|code_row| code_row.to_h}
          expect(matching_array.length).to eq 7
          expect(matching_array).to include(
            {dept_name: 'FSSEM', catalog_id: '', dept_code: 'FSSEM', include_in_oec: true},
            {dept_name: 'CHEM', catalog_id: '24', dept_code: 'FSSEM', include_in_oec: true},
            {dept_name: 'CLASSIC', catalog_id: '24', dept_code: 'FSSEM', include_in_oec: true},
            {dept_name: 'CLASSIC', catalog_id: '39D', dept_code: 'FSSEM', include_in_oec: true},
            {dept_name: 'MCELLBI', catalog_id: '90A', dept_code: 'FSSEM', include_in_oec: true},
            {dept_name: 'MCELLBI', catalog_id: '90B', dept_code: 'FSSEM', include_in_oec: true},
            {dept_name: 'PORTUG', catalog_id: '24', dept_code: 'FSSEM', include_in_oec: true}
          )
        end
      end
    end
  end

  describe '#catalog_id_home_department' do
    let(:home_dept) { subject.catalog_id_home_department(dept_name, catalog_id) }
    let(:dept_name) {'PORTUG'}
    context 'catalog ID is unexceptional' do
      let(:catalog_id) {'101'}
      it 'defaults to nil' do
        expect(home_dept).to be_blank
      end
    end
    context 'catalog ID explicitly assigned to another department' do
      let(:catalog_id) {'66OTHER'}
      it 'finds the home dept_name of the assigned dept_code' do
        expect(home_dept).to eq 'A,RESEC'
      end
    end
    context 'catalog ID found in a virtual department' do
      let(:catalog_id) {'24'}
      it 'returns the virtual department name' do
        expect(home_dept).to eq 'FSSEM'
      end
    end
  end

  describe '#excluded_courses' do
    let(:excluded_catalog_ids) { subject.excluded_courses('PORTUG', 'LPSPP').collect {|c| c[:catalog_id]} }
    it 'includes explicitly excluded courses' do
      expect(excluded_catalog_ids).to include '86EXCLUDE'
    end
    it 'includes courses explicitly assigned to another department' do
      expect(excluded_catalog_ids).to include '66OTHER'
    end
    it 'includes courses found  in a virtual department' do
      expect(excluded_catalog_ids).to include '24'
    end
  end

  describe '#dept_names_for_code' do
    it 'includes all mapped departments, even if catalog-ID-specific' do
      expect(subject.dept_names_for_code 'MBARC').to include(
        'A,RESEC',
        'PORTUG'
      )
    end
  end

end
