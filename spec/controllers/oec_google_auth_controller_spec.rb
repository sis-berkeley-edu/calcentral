describe OecGoogleAuthController do

  let(:oec_user_id) { random_id }
  let(:settings) {
    {
      uid: oec_user_id,
      client_id: Settings.oec.google.client_id,
      client_secret: Settings.oec.google.client_secret,
      scope: Settings.oec.google.scope
    }
  }
  let(:session_user_id) { random_id }
  let(:can_administer_oec) { true }
  let(:app_id) { GoogleApps::Proxy::OEC_APP_ID }
  let(:params) { {} }

  before do
    session['user_id'] = session_user_id
    allow(Oec::Administrator).to receive(:is_admin?).with(session_user_id).and_return can_administer_oec
    allow(Settings.oec.google).to receive(:marshal_dump).and_return settings
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
      allow(GoogleApps::Proxy).to receive(:access_granted?).with(session_user_id).and_return true
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
            oec_user_id,
            app_id,
            access_token,
            refresh_token,
            0,
            hash_including(:expiration_time))
          expect(User::Oauth2Data).to receive(:update_google_email!).never
        end
        it 'should record new client_id and client_secret' do
          post :handle_callback, params
          expect(response).to have_http_status 302
        end
      end
    end
  end

  context 'cannot administer OEC' do
    let(:can_administer_oec) { false }

    it 'should reject user as unauthorized' do
      post :refresh_tokens
      expect(response).to have_http_status 403
    end
  end

  context 'indirectly authenticated' do
    before do
      allow(GoogleApps::Proxy).to receive(:access_granted?).with(session_user_id).and_return true
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
