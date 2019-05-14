describe MyCampusLinksController do
  it_should_behave_like 'a user authenticated api endpoint' do
    let(:make_request) { get :get_feed }
  end
end
