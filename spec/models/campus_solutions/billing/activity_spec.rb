describe CampusSolutions::Billing::Activity do

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the billing feature flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:summary]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::Billing::Activity.new(fake: true, user_id: '61889') }
    it_should_behave_like 'a proxy that gets data'
  end

end
