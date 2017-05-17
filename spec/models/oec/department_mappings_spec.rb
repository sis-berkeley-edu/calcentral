describe Oec::DepartmentMappings do

  before do
    Oec::CourseCode.create(dept_name: 'A,RESEC', catalog_id: '', dept_code: 'MBARC', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'BIOLOGY', catalog_id: '1A', dept_code: 'IMMCB', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'BIOLOGY', catalog_id: '1AL', dept_code: 'IMMCB', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'BIOLOGY', catalog_id: '1B', dept_code: 'IBIBI', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'BIOLOGY', catalog_id: '1BL', dept_code: 'IBIBI', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'CATALAN', catalog_id: '', dept_code: 'LPSPP', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'CHEM', catalog_id: '', dept_code: 'CCHEM', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'CHEM', catalog_id: '54GET', dept_code: 'UNFRNDLY', include_in_oec: false)
    Oec::CourseCode.create(dept_name: 'INTEGBI', catalog_id: '', dept_code: 'IBIBI', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'MCELLBI', catalog_id: '', dept_code: 'IMMCB', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'PORTUG', catalog_id: '', dept_code: 'LPSPP', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'PORTUG', catalog_id: '86EXCLUDE', dept_code: 'LPSPP', include_in_oec: false)
    Oec::CourseCode.create(dept_name: 'PORTUG', catalog_id: '66OTHER', dept_code: 'MBARC', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'SPANISH', catalog_id: '', dept_code: 'LPSPP', include_in_oec: true)
  end

  describe '#by_dept_code' do
    # Options are a choice of {dept_code: [dept_codes...]} or {include_in_oec: true}
    subject(:mappings) { Oec::DepartmentMappings.new.by_dept_code(opts) }
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
        expect(mappings.keys).to eq ['CCHEM', 'LPSPP', 'UNFRNDLY']
        expect(mappings['CCHEM'].length).to eq 1
        expect(mappings['UNFRNDLY'].length).to eq 1
      end
    end
    context 'all included departments' do
      let(:opts) { {include_in_oec: true} }
      it 'includes all enabled dept_codes' do
        expect(mappings.keys).to include('CCHEM', 'IBIBI', 'IMMCB', 'LPSPP', 'MBARC')
        matching_array = mappings['LPSPP'].map {|code_row| code_row.to_h}
        expect(matching_array.length).to eq 3
        expect(matching_array).not_to include(
          {dept_name: 'PORTUG', catalog_id: '86EXCLUDE', dept_code: 'LPSPP', include_in_oec: false}
        )
      end
    end
  end

end
