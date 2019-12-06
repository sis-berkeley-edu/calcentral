describe MyClearingHouseUrlController do
  let(:session_user_id) { '61889' }
  let (:clearing_house_uri) { URI.parse(Settings.clearing_house_proxy.base_url) }
  before do
    stub_request(:any, /.*#{clearing_house_uri.hostname}.*/).to_return(status: 404)
  end

  context 'handling proxy errors' do
    subject {get :redirect, params: { user_id: session_user_id } }
    it 'should rescue' do
      expect(subject).to redirect_to('/404')
    end
  end
end
