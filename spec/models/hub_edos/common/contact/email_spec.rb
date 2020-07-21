describe HubEdos::Common::Contact::Email do
  let(:attributes) do
    {
      'type' => {
        'code' => 'CAMP',
        'description' => 'Campus',
      },
      'emailAddress' => 'example@berkeley.edu',
      "primary" => true,
      "disclose" => false,
      'uiControl' => {
        'code' => 'D',
        'description' => 'Display Only',
      },
    }
  end
  subject { described_class.new(attributes) }
  its(:type) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its('type.code') { should eq('CAMP') }
  its(:email_address) { should eq('example@berkeley.edu') }
  its(:primary) { should eq(true) }
  its(:disclose) { should eq(false) }

  describe '#to_json' do
    it 'returns expected json' do
      json = subject.to_json
      hash_result = JSON.parse(json)
      expect(hash_result['type']['code']).to eq 'CAMP'
      expect(hash_result['type']['description']).to eq 'Campus'
      expect(hash_result['emailAddress']).to eq 'example@berkeley.edu'
      expect(hash_result['primary']).to eq true
      expect(hash_result['disclose']).to eq false
      expect(hash_result['uiControl']['code']).to eq 'D'
      expect(hash_result['uiControl']['description']).to eq 'Display Only'
    end
  end
end


