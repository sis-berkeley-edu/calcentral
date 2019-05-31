describe User::Oauth2Data do

  let(:user_id) { random_id }
  let(:app_id) { GoogleApps::Proxy::APP_ID }
  let(:access_token) { random_string 10 }
  let(:refresh_token) { random_string 10 }

  it 'should not store plaintext access tokens' do
    allow_any_instance_of(User::Oauth2Data).to receive(:decrypt_tokens).and_return nil
    oauth2 = User::Oauth2Data.new(uid: user_id, app_id: app_id, access_token: 'plaintext')
    expect(oauth2.save).to be true
    access_token = User::Oauth2Data.get(user_id, app_id)[:access_token]
    expect(access_token).to_not eq 'plaintext'
  end

  it 'should return decrypted access tokens' do
    oauth2 = User::Oauth2Data.new(uid: user_id, app_id: app_id, access_token: access_token)
    expect(Cache::UserCacheExpiry).to receive(:notify).once
    expect(oauth2.save).to be_truthy
    access_token = User::Oauth2Data.get(user_id, app_id)[:access_token]
    expect(access_token).to eq access_token
  end

  it 'should be able to update existing tokens' do
    User::Oauth2Data.new_or_update(
      user_id,
      app_id,
      access_token,
      refresh_token,
      1)
    tokens = User::Oauth2Data.get(user_id, app_id)
    expect(tokens[:access_token]).to eq access_token
    expect(tokens[:refresh_token]).to eq refresh_token
    expect(tokens[:expiration_time]).to eq 1
    expect(Cache::UserCacheExpiry).to receive(:notify).once
    updated_access_token = random_string 10
    User::Oauth2Data.new_or_update(user_id, app_id, updated_access_token)
    updated_tokens = User::Oauth2Data.get(user_id, app_id)
    expect(updated_tokens[:access_token]).to eq updated_access_token
    expect(updated_tokens[:refresh_token]).to be_empty
    expect(updated_tokens[:expiration_time]).to eq 0
    expect(updated_tokens).to_not eq tokens
  end

  it 'should be able to store additional app_data with tokens' do
    app_data = {
      foo: 'baz'
    }
    User::Oauth2Data.new_or_update(
      user_id,
      app_id,
      access_token,
      refresh_token,
      1,
      app_data: app_data)
    tokens = User::Oauth2Data.get(user_id, app_id)
    expect(tokens[:app_data]).to eq app_data
  end

  it 'should be able to handle a malformed app_data entry' do
    app_data_null = {
      'clc_null' => true
    }
    suppress_rails_logging do
      User::Oauth2Data.new_or_update(
        user_id,
        app_id,
        access_token,
        refresh_token,
        1,
        app_data: '')
    end
    tokens = User::Oauth2Data.get(user_id, app_id)
    expect(tokens[:app_data]).to eq app_data_null
  end

  it 'should be able to get and update google email for authenticated users' do
    User::Oauth2Data.new_or_update(
      user_id,
      app_id,
      access_token,
      refresh_token,
      1)
    expect(User::Oauth2Data.get_google_email(user_id)).to be_blank
    user_info = GoogleApps::Userinfo.new(fake: true).user_info
    allow(GoogleApps::Userinfo).to receive(:user_info).and_return user_info
    User::Oauth2Data.update_google_email! user_id
    expect(User::Oauth2Data.get_google_email user_id).to eq 'tammi.chang.clc@gmail.com'
  end

  it 'should fail updating canvas email on a non-existant Canvas account' do
    allow_any_instance_of(Canvas::SisUserProfile).to receive(:sis_user_profile).and_return(
      statusCode: 404,
      error: [
        {
          message: 'Resource not found.'
        }
      ]
    )
    User::Oauth2Data.new_or_update(
      user_id,
      Canvas::Proxy::APP_ID,
      access_token,
      refresh_token,
      1)
    expect(User::Oauth2Data.get_canvas_email user_id).to be_blank
    User::Oauth2Data.update_canvas_email! user_id
    expect(User::Oauth2Data.get_canvas_email user_id).to be_blank
  end

  it 'should successfully update a canvas email ' do
    user_profile = Canvas::SisUserProfile.new(fake: true, user_id: 300846)
    allow(Canvas::SisUserProfile).to receive(:new).and_return user_profile
    User::Oauth2Data.new_or_update(
      user_id,
      Canvas::Proxy::APP_ID,
      access_token,
      refresh_token,
      1)
    expect(User::Oauth2Data.get_canvas_email user_id).to be_blank
    User::Oauth2Data.update_canvas_email! user_id
    expect(User::Oauth2Data.get_canvas_email user_id).to_not be_blank
  end

  it 'should invalidate cache when tokens are deleted' do
    oauth2 = User::Oauth2Data.new(
      uid: user_id,
      app_id: app_id,
      access_token: access_token)
    expect(Cache::UserCacheExpiry).to receive(:notify).exactly(2).times
    expect(oauth2.save).to be true
    User::Oauth2Data.destroy_all(
      uid: user_id,
      app_id: app_id)
    access_token = User::Oauth2Data.get(user_id, app_id)[:access_token]
    expect(access_token).to be_nil
  end

  it 'should remove dismiss_reminder app_data when a new google token is stored' do
    expect(User::Oauth2Data.dismiss_google_reminder(user_id)).to be true
    expect(User::Oauth2Data.is_google_reminder_dismissed(user_id)).to be true
    User::Oauth2Data.new_or_update(user_id, GoogleApps::Proxy::APP_ID, access_token, refresh_token)
    expect(User::Oauth2Data.is_google_reminder_dismissed user_id).to be_empty
  end

  it 'new_or_update should merge new app_data into existing app_data' do
    User::Oauth2Data.new_or_update(user_id, GoogleApps::Proxy::APP_ID, access_token, refresh_token, 0, {app_data:{foo: 'foo?'}})
    expect(User::Oauth2Data.send(:get_appdata_field, GoogleApps::Proxy::APP_ID, user_id, :foo)).to eq 'foo?'
    User::Oauth2Data.new_or_update(user_id, GoogleApps::Proxy::APP_ID, access_token, refresh_token, 0, {app_data:{baz: 'baz!'}})
    expect(User::Oauth2Data.send(:get_appdata_field, GoogleApps::Proxy::APP_ID, user_id, :baz)).to eq 'baz!'
    expect(User::Oauth2Data.send(:get_appdata_field, GoogleApps::Proxy::APP_ID, user_id, :foo)).to eq 'foo?'
  end
end
