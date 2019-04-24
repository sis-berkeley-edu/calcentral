describe HubEdos::V1::StudentAttributes do
  context 'mock proxy' do
    let(:include_fields) { nil }
    let(:proxy) { HubEdos::V1::StudentAttributes.new(fake: true, user_id: '61889', include_fields: include_fields) }
    subject { proxy.get }

    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['student']).to be
      expect(subject[:feed]['student']['studentAttributes'].count).to eq 14
      expect(subject[:feed]['student']['studentAttributes'][0]).to be
      expect(subject[:feed]['student']['studentAttributes'][0]['type']['code']).to eq 'AHC'
      expect(subject[:feed]['student']['studentAttributes'][0]['type']['description']).to eq 'American History - Completed'
      expect(subject[:feed]['student']['studentAttributes'][0]['type']['code']).to eq 'AHC'
    end

    it 'should return default fields only' do
      fields = subject[:feed]['student']
      %w(studentAttributes).each do |key|
        expect(fields[key]).to be_present
      end
      expect(fields['confidential']).to be_blank
      expect(fields['identifiers']).to be_blank
      expect(fields['affiliations']).to be_blank
    end
  end
end
