describe CampusSolutions::LanguageCodeController do
  context 'language codes feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:user_id) { '12345' }
      let(:feed_path) { ['feed','accomplishments'] }
      it_behaves_like 'a successful feed'
    end
  end
end
