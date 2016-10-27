describe GoogleApps::CredentialStore do

  let(:app_id) { GoogleApps::Proxy::APP_ID }
  let(:uid) { random_id }
  let(:settings) { GoogleApps::CredentialStore.settings_of app_id }
  let(:access_token) { random_string(10) }
  let(:refresh_token) { random_string(10) }
  let(:oauth2_tokens) {
    {
      access_token: access_token,
      refresh_token: refresh_token
    }
  }
  context '#fake' do
    let(:opts) { {} }
    let(:client_id) { settings[:client_id] }
    let(:client_secret) { settings[:client_secret] }
    let(:scope) { settings[:scope] }
    let(:oauth2_data) { oauth2_tokens.merge expiration_time: 1 }
    let(:store) { GoogleApps::CredentialStore.new(app_id, uid, opts) }

    before {
      allow(User::Oauth2Data).to receive(:get).with(uid, app_id).and_return oauth2_data
    }

    context 'uid has access and refresh token in the database' do
      it 'should load default calcentral credentials' do
        c = store.load_credentials
        expect(c[:client_id]).to eq client_id
        expect(c[:client_secret]).to eq client_secret
        expect(c[:token_credential_uri]).to_not be_nil
        expect(c[:access_token]).to eq oauth2_data[:access_token]
        expect(c[:refresh_token]).to eq oauth2_data[:refresh_token]
        expect(c[:expiration_time]).to be > 0
        expect(c[:expires_in]).to_not be_nil
        expect(c[:issued_at]).to_not be_nil
        expect(c[:scope]).to eq scope
      end
    end

    context 'infer expiration time' do
      let(:issued_at) { 10 }
      let(:expires_in) { 100 }
      let(:opts) {
        {
          issued_at: issued_at,
          expires_in: expires_in
        }
      }

      before {
        expect(User::Oauth2Data).to receive(:new_or_update).with(uid, app_id, access_token, refresh_token, kind_of(Numeric), anything)
      }
      it 'should compute expiration_time on the fly' do
        c = store.load_credentials
        c[:expiration_time] = nil
        # Expected behavior is asserted in the 'before' block above
        store.write_credentials c
      end
    end

    context 'OEC' do
      let(:app_id) { GoogleApps::Proxy::OEC_APP_ID }

      it 'should find settings per app_id' do
        expect(store.load_credentials).to_not be_nil
      end
    end

    context 'errors' do
      it 'should raise error if uid is blank' do
        expect{ GoogleApps::CredentialStore.new(app_id, '  ') }.to raise_error ArgumentError
      end

      context 'no such user' do
        let(:oauth2_data) { {} }

        it 'should return nil' do
          expect(store.load_credentials).to be_nil
        end
      end

      context 'blank refresh_token' do
        let(:refresh_token) { ' ' }

        it 'should raise error' do
          store = GoogleApps::CredentialStore.new(random_string(3), random_id)
          expect{ store.write_credentials({}) }.to raise_error
        end
      end
    end
  end

  context '#real', testext: true, order: :defined do
    let(:options) { oauth2_tokens.merge issued_at: 1440628381, expires_in: 3600, app_data: 'johndoe@berkeley.edu' }

    before do
      existing_data = User::Oauth2Data.get(uid, app_id)
      raise 'The random and very large id matches real data. Abort!' if existing_data.any?
      # Values in options hash will be written to the database
      GoogleApps::CredentialStore.new(app_id, uid).write_credentials options
    end

    after do
      User::Oauth2Data.remove(uid, app_id)
    end

    it 'should find no match in oauth2_data' do
      expiration_time = random_id.to_i
      c = GoogleApps::CredentialStore.new(app_id, uid, expiration_time: expiration_time).load_credentials
      expect(c).to_not be_nil
      expect(c[:access_token]).to eq options[:access_token]
      expect(c[:refresh_token]).to eq options[:refresh_token]
      expect(c[:expiration_time]).to eq expiration_time
      expect(c[:expires_in]).to eq 3600
      expect(c[:client_id]).to eq settings[:client_id]
      expect(c[:client_secret]).to eq settings[:client_secret]
      expect(c[:scope]).to eq settings[:scope]
    end
  end
end
