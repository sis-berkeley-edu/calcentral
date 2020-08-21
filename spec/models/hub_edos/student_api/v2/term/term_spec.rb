describe HubEdos::StudentApi::V2::Term::Term do
  let(:attributes) do
    {
      'id' => '2242',
      'name' => '2024 Spring',
      'category' => {
        'code' => 'R',
        'description' => 'Regular Term'
      },
      'academicYear' => '2024',
      'beginDate' => '2024-01-01',
      'endDate' => '2024-05-15'
    }
  end
  subject { described_class.new(attributes) }

  context 'when no attributes present' do
    let(:attributes) { nil }
    its(:id) { should eq nil }
    its(:name) { should eq nil }
    its(:category) { should eq nil }
    its(:academic_career) { should eq nil }
    its(:temporal_position) { should eq nil }
    its(:academic_year) { should eq nil }
    its(:begin_date) { should eq nil }
    its(:end_date) { should eq nil }
    its(:weeks_of_instruction) { should eq nil }
    its(:holiday_schedule) { should eq nil }
    its(:census_date) { should eq nil }
    describe '#to_json' do
      it 'returns json representation' do
        json_result = subject.to_json
        hash_result = JSON.parse(json_result)
        expect(hash_result).to eq({})
      end
    end
  end

  its(:id) { should eq '2242' }
  its(:name) { should eq '2024 Spring' }
  its(:category) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:begin_date) { should eq Date.parse('2024-01-01') }
  its(:end_date) { should eq Date.parse('2024-05-15') }

  describe '#to_json' do
    it 'returns json representation' do
      json_result = subject.to_json
      hash_result = JSON.parse(json_result)
      expect(hash_result['id']).to eq '2242'
      expect(hash_result['name']).to eq '2024 Spring'
      expect(hash_result['category']['code']).to eq 'R'
      expect(hash_result['category']['description']).to eq 'Regular Term'
      expect(hash_result['academicYear']).to eq '2024'
      expect(hash_result['beginDate']).to eq '2024-01-01'
      expect(hash_result['endDate']).to eq '2024-05-15'
    end
  end
end
