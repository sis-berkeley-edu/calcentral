describe CampusSolutions::EmergencyContactsController do
  context 'emergency contacts feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:user_id) { '1024600' }
      let(:feed_path) { ['feed','students'] }
      it_behaves_like 'a successful feed'
    end
  end
end
