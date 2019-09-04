describe MyHoldsController do
  before do
    allow(Settings.hub_edos_proxy).to receive(:fake).and_return true
  end
  let(:user_id) { random_id }

  describe '#get_feed' do
    let(:feed) { :get_feed }

    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:feed_path) { ['feed','holds'] }
      it_behaves_like 'a successful feed'
    end
  end
end
