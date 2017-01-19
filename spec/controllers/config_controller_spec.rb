describe ConfigController do

  context 'unauthenticated' do
    subject {
      get :get
      JSON.parse response.body
    }
    it 'should return a JSON feed' do
      assert_response :success
      expect(response).to be_success
      expect(subject).is_a? Hash
    end
    it 'should contain the correct properties' do
      expect(subject).to have_at_most(8).items
      %w(applicationVersion clientHostname googleAnalyticsId sentryUrl csrfToken csrfParam providedServices).each do |key|
        expect(subject[key]).is_a? String
      end
    end
    it 'should not contain sensitive data' do
      expect(subject).to_not have_key 'proxies'
    end
  end
  context 'authenticated' do
    let(:user_id) { random_id }
    subject {
      session['user_id'] = user_id
      get :get
      JSON.parse response.body
    }
    context 'ordinary user' do
      it 'should contain the uid property' do
        expect(subject).to have_at_most(8).items
        expect(subject['uid']).to eq user_id
      end
      it 'should not contain sensitive data' do
        expect(subject).to_not have_key 'proxies'
      end
    end
    context 'user can administrate' do
      before do
        expect(AuthenticationState).to receive(:new).and_return double(
          policy: double(can_administrate?: true),
          classic_viewing_as?: false,
          authenticated_as_advisor?: false,
          authenticated_as_delegate?: false
        )
      end
      it 'should contain sensitive data' do
        proxies = subject['proxies']
        expect(proxies).to_not be_nil
        %w(campusSolutions hubEdos calnetCrosswalk casServer ldapHost).each do |key|
          expect(proxies).to have_key key
        end
      end
    end
  end
end
