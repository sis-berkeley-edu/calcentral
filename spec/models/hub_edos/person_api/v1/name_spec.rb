describe HubEdos::PersonApi::V1::Name do
  let(:attributes) do
    {
      "type" => {
        "code" => "PRF",
        "description" => "Preferred"
      },
      "familyName" => "Bear",
      "givenName" => "Oski Golden",
      "formattedName" => "Oski Golden Bear",
      "preferred" => true,
      "disclose" => false,
      "uiControl" => {
        "code" => "U",
        "description" => "Edit - No Delete"
      },
      "fromDate" => "2019-09-23"
    }
  end
  subject { described_class.new(attributes) }
  its(:type) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its('type.code') { should eq('PRF') }
  its('type.description') { should eq('Preferred') }
  its(:from_date) { should be_an_instance_of Date }
  its('from_date.to_s') { should eq '2019-09-23' }
  its(:ui_control) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }

  describe '#to_json' do
    let(:result) { JSON.parse(subject.to_json) }
    it 'should include type hash' do
      expect(result['type']).to eq({ 'code' => 'PRF', 'description' => 'Preferred' })
    end
    it 'should include family name' do
      expect(result['familyName']).to eq('Bear')
    end
    it 'should include given name' do
      expect(result['givenName']).to eq('Oski Golden')
    end
    it 'should include formatted name' do
      expect(result['formattedName']).to eq('Oski Golden Bear')
    end
    it 'should include preferred boolean' do
      expect(result['preferred']).to eq(true)
    end
    it 'should include disclose boolean' do
      expect(result['disclose']).to eq(false)
    end
    it 'should include from date string' do
      expect(result['fromDate']).to eq('2019-09-23')
    end
    it 'should include ui control descriptor hash' do
      expect(result['uiControl']).to eq({ 'code' => 'U', 'description' => 'Edit - No Delete' })
    end
  end
end
