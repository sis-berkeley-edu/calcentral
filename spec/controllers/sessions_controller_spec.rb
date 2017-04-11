describe SessionsController do
  let(:cookie_hash) { {} }
  let(:response_body) { nil }

  describe '#lookup' do
    let(:omniauth_auth) do
      {
        'uid' => user_id
      }
    end
    before(:each) do
      @request.env['omniauth.auth'] = omniauth_auth
      cookie_hash = {}
      :logout
    end

    context 'session management' do
      let(:user_id) { random_id }

      it 'logs the user out when CAS uid does not match original user uid' do
        expect(controller).to receive(:cookies).and_return cookie_hash
        :create_reauth_cookie
        different_user_id = "some_other_#{user_id}"
        session[SessionKey.original_user_id] = different_user_id
        session['user_id'] = different_user_id

        get :lookup, renew: 'true'

        expect(@response.status).to eq 302
        expect(cookie_hash[:reauthenticated]).to be_nil
        expect(session).to be_empty
        expect(cookie_hash).to be_empty
      end
      it 'will create reauth cookie if original user_id not found in session' do
        expect(controller).to receive(:cookies).and_return cookie_hash
        session['user_id'] = user_id

        get :lookup, renew: 'true'

        cookie_hash[:reauthenticated].should_not be_nil
        reauth_cookie = cookie_hash[:reauthenticated]
        expect(reauth_cookie[:value]).to be true
        expect(reauth_cookie[:expires]).to be > Date.today
        expect(session).to_not be_empty
        expect(session['user_id']).to eq user_id
      end
      it 'will reset session when CAS uid does not match uid in session' do
        expect(controller).to receive(:cookies).and_return cookie_hash
        :create_reauth_cookie
        session[SessionKey.original_user_id] = user_id
        session['user_id'] = user_id

        get :lookup, renew: 'true'

        reauth_cookie = cookie_hash[:reauthenticated]
        expect(reauth_cookie).to_not be_nil
        expect(reauth_cookie[:value]).to be true
        expect(reauth_cookie[:expires]).to be > Date.today

        expect(session).to_not be_empty
        expect(session['user_id']).to eq user_id
      end
      it 'will redirect to CAS logout, despite LTI user session, when CAS user_id is an unexpected value' do
        expect(controller).to receive(:cookies).and_return cookie_hash
        session['lti_authenticated_only'] = true
        session['user_id'] = "some_other_#{user_id}"

        # No 'renew' param
        get :lookup

        expect(session).to be_empty
        expect(cookie_hash).to be_empty
      end
    end

    context 'with SAML attributes' do
      let(:cs_id) { random_id }
      let(:user_id) { random_id }
      let(:omniauth_auth) do
        dbl = double
        allow(dbl).to receive(:[]).with('uid').and_return user_id
        allow(dbl).to receive(:extra).and_return({
          'berkeleyEduCSID' => cs_id
        })
        dbl
      end
      it 'will cache the Campus Solutions ID if provided through CAS' do
        session['user_id'] = user_id
        expect(User::Identifiers).to receive(:cache).with(user_id, cs_id)
        get :lookup
      end
    end
  end

  describe '#reauth_admin' do
    it 'will redirect to designated reauth path' do
      # The after hook below will make the appropriate assertions
      get :reauth_admin
    end
  end

end
