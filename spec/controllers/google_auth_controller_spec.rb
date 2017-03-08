describe GoogleAuthController do

  let(:user_id) { random_id }
  let(:settings) {
    {
      client_id: Settings.google_proxy.client_id,
      client_secret: Settings.google_proxy.client_secret,
      scope: Settings.google_proxy.scope
    }
  }
  let(:app_id) { GoogleApps::Proxy::APP_ID }
  let(:params) { {} }

  before do
    session['user_id'] = user_id
  end

  describe 'Google transaction' do
    let(:google_url) { random_string 10 }
    let(:omit_domain_restriction) { false }
    let(:default_scope) { settings[:scope] }
    let(:expected_scope) { default_scope }
    let(:client) {
      expect(Google::APIClient).to receive(:new).and_return (google_api = double)
      expect(google_api).to receive(:authorization).and_return (client = double)
      client
    }

    before do
      allow(GoogleApps::Proxy).to receive(:access_granted?).with(user_id).and_return true
      allow(Google::APIClient).to receive(:authorization_uri).and_return google_url
    end

    before do
      expect(client).to receive(:client_id=).with settings[:client_id]
      expect(client).to receive(:client_secret=).with settings[:client_secret]
      expect(client).to receive(:redirect_uri=)
      expect(client).to receive(:state=)
      expect(client).to receive(:authorization_uri=).exactly(omit_domain_restriction ? 0 : 1).times
    end

    describe '#refresh_tokens' do
      before do
        expect(client).to receive :authorization_uri
        expect(client).to receive(:scope=).and_return expected_scope
        expect(client).to receive :update!
      end

      subject do
        post :refresh_tokens, params
      end

      context 'user can refresh Google OAuth tokens' do
        let(:params) { {} }

        context 'omit domain restriction' do
          # The 'force_domain' param determines use of client.authorization_uri=
          let(:params) { { 'force_domain' => 'false' } }
          let(:omit_domain_restriction) { true }

          it 'should redirect to Google with ' do
            post :refresh_tokens, params
            expect(response).to have_http_status 302
          end
        end

        context 'custom scope' do
          let(:params) { { 'scope' => 'extra1 extra2' } }
          let(:expected_scope) { "#{default_scope} extra1 extra2" }
          it 'should redirect to Google' do
            post :refresh_tokens, params
            expect(response).to have_http_status 302
          end
        end
      end
    end

    describe '#process_callback' do
      context 'handle Google callback' do
        let(:params) { { 'code' => random_string(10) } }
        let(:access_token) { random_string 10 }
        let(:refresh_token) { random_string 10 }
        before do
          expect(client).to receive(:code=).with params['code']
          expect(client).to receive :fetch_access_token!
          expect(client).to receive(:expires_in).and_return nil
          expect(client).to receive(:access_token).and_return access_token
          expect(client).to receive(:refresh_token).and_return refresh_token
          expect(User::Oauth2Data).to receive(:new_or_update).with(
            user_id,
            app_id,
            access_token,
            refresh_token,
            0,
            hash_including(:expiration_time)
          )
          expect(User::Oauth2Data).to receive(:update_google_email!).with(user_id)
        end
        it 'should record new client_id and client_secret' do
          post :handle_callback, params
          expect(response).to have_http_status 302
        end
      end
    end
  end

  describe '#error' do
    context 'Google reports an error' do
      before do
        expect(Google::APIClient).to receive(:new).never
        expect(User::Oauth2Data).to receive(:remove).with(user_id, app_id)
      end

      it 'should not record client_id and client_secret' do
        post :handle_callback, { 'error' => 'Houston, we have a problem!' }
        expect(response).to have_http_status 302
      end
    end
  end

  describe '#dismiss_reminder' do
    it 'should store a dismiss_reminder key-value when there is no token for a user' do
      allow(GoogleApps::Proxy).to receive(:access_granted?).with(user_id).and_return false
      post :dismiss_reminder, { format: 'json' }
      expect(response).to have_http_status :success
      response_body = JSON.parse response.body
      expect(response_body['result']).to be true
    end

    it 'should not store a dismiss_reminder key-value when there is an existing token' do
      allow(GoogleApps::Proxy).to receive(:access_granted?).with(user_id).and_return true
      post :dismiss_reminder, { format: 'json' }
      expect(response).to have_http_status :success
      response_body = JSON.parse response.body
      expect(response_body['result']).to be false
    end
  end

  describe '#current_scope' do
    let(:access_granted) { true }
    before do
      expect(GoogleApps::Proxy).to receive(:access_granted?).with(user_id, GoogleApps::Proxy::APP_ID).and_return access_granted
    end
    subject {
      post :current_scope, { format: 'json' }
      expect(response).to have_http_status :success
      json = JSON.parse response.body
      json['currentScope']
    }

    context 'access granted' do
      let(:current_scope) { [ random_string(5), random_string(5) ] }
      before do
        expect(GoogleApps::Userinfo).to receive(:new).with(user_id: user_id, app_id: GoogleApps::Proxy::APP_ID).and_return (user_info = double)
        expect(user_info).to receive(:current_scope).and_return current_scope
      end

      it 'should return scope information' do
        expect(subject).to eq current_scope
      end
    end
    context 'access not granted' do
      let(:access_granted) { false }
      it 'should return scope information' do
        expect(subject).to eq []
      end
    end
  end

  describe '#remove_authorization' do
    before do
      expect(GoogleApps::Revoke).to receive(:new).with(user_id: user_id).and_return(google = double)
      expect(google).to receive :revoke
      expect(User::Oauth2Data).to receive(:remove).with(user_id, app_id)
      expect(Cache::UserCacheExpiry).to receive :notify
    end

    it 'should delete all tokens, everywhere' do
      post :remove_authorization
    end
  end

  context 'indirectly authenticated' do
    before do
      allow(GoogleApps::Proxy).to receive(:access_granted?).with(user_id).and_return true
      allow(Google::APIClient).to receive(:new).never
    end
    subject do
      post :refresh_tokens, params
    end
    context 'viewing as' do
      before do
        session[SessionKey.original_user_id] = random_id
      end
      it { is_expected.not_to have_http_status :success }
    end
    context 'LTI embedded' do
      before do
        session['lti_authenticated_only'] = true
      end
      it { is_expected.not_to have_http_status :success }
    end
  end
end
