describe HubEdos::V1::Student do

  context 'mock proxy' do
    let(:proxy) { HubEdos::V1::Student.new(fake: true, user_id: '61889') }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['student']).to be
      expect(subject[:feed]['student']['identifiers'][0]['type']).to be
      expect(subject[:feed]['student']['addresses'][0]['state']).to eq 'CA'
      expect(subject[:feed]['student']['addresses'][0]['postal']).to eq '454554'
      expect(subject[:feed]['student']['addresses'][0]['country']).to eq 'USA'
    end
  end
end
