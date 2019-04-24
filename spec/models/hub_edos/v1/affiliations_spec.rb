describe HubEdos::V1::Affiliations do
  context 'mock proxy' do
    let(:proxy) { HubEdos::V1::Affiliations.new(fake: true, user_id: '61889') }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['student']).to be
      expect(subject[:feed]['student']['affiliations'].length).to eq 2
      expect(subject[:feed]['student']['identifiers'].length).to eq 1
    end
  end
end
