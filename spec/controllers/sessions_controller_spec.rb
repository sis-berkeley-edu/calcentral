describe SessionsController do
  let(:cookie_hash) { {} }
  let(:response_body) { nil }

  describe '#lookup' do
    before(:each) do
      @request.env['omniauth.auth'] = {
        'uid' => user_id
      }
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

    context 'campus solutions' do
      let(:user_id) { '12352' }

      it 'will cache the Campus Solutions IDs' do
        session['user_id'] = user_id

        get :lookup

        crosswalk = CalnetCrosswalk::ByUid.new user_id: user_id
        expect(crosswalk.lookup_campus_solutions_id).to eq '13320459'
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
