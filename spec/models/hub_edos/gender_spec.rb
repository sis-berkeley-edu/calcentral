describe HubEdos::Gender do

  context 'mock proxy' do
    let(:include_fields) { nil }
    let(:proxy) { HubEdos::Gender.new(fake: true, user_id: '61889', include_fields: include_fields) }
    subject { proxy.get }

    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['student']).to be
      expect(subject[:feed]['student']['gender']['genderOfRecord']['code']).to eq 'M'
      expect(subject[:feed]['student']['gender']['discloseGenderOfRecord']).to eq true
    end

    it 'should return default fields only' do
      fields = subject[:feed]['student']
      %w(gender).each do |key|
        expect(fields[key]).to be_present
      end
      expect(fields['identifiers']).to be_blank
      expect(fields['affiliations']).to be_blank
    end
  end

end
