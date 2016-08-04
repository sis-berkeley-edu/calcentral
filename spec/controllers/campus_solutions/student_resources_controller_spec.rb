describe CampusSolutions::StudentResourcesController do
  context 'student resources feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:user_id) { random_id }
      let(:feed_key) { 'resources' }
      it_behaves_like 'a successful feed'
    end
  end
end
