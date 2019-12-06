describe StoredUsersController do

  let(:error_response) do
    {
      'success' => false,
      'message' => 'Please provide a numeric UID.'
    }
  end
  let(:success_response) do
      {
        'success' => true
      }
  end
  let(:users_found) do
    {
      :saved => [
        {
          :ldapUid => '1'
        }
      ],
      :recent => [
        {
          :ldapUid => '2'
        }
      ]
    }
  end
  let(:session_user_id) { random_id }

  before do
    session['user_id'] = session_user_id
    allow(User::Auth).to receive(:where).and_return [ User::Auth.new(uid: session_user_id, is_superuser: true, active: true) ]
  end

  describe '#get' do
    it 'should return stored users' do
      User::StoredUsers.should_receive(:get).with(session_user_id).and_return users_found

      get :get
      expect(response).to be_successful
      users = JSON.parse(response.body)['users']
      expect(users).to be_a Hash
      expect(users['saved']).to be_an Array
      expect(users['recent']).to be_an Array
      expect(users['saved'][0]['ldapUid']).to eq '1'
      expect(users['recent'][0]['ldapUid']).to eq '2'
    end
  end

  describe '#store_saved_uid' do
    it 'should return error_response on invalid uid' do
      post :store_saved_uid, params: { format: 'json', uid: 'not_numeric' }
      expect(response.status).to eq 400
      json_response = JSON.parse response.body
      expect(json_response['success']).to be false
      expect(json_response['message']).to eq 'Please provide a numeric UID.'
    end

    it 'should return success_response on valid uid' do
      User::StoredUsers.should_receive(:store_saved_uid).with(session_user_id, '100').and_return success_response

      post :store_saved_uid, params: { format: 'json', uid: '100' }
      expect(response).to be_successful
      json_response = JSON.parse response.body
      expect(json_response['success']).to be true
    end
  end

  describe '#store_recent_uid' do
    it 'should return error_response on invalid uid' do
      post :store_recent_uid, params: { format: 'json', uid: 'not_numeric' }
      expect(response.status).to eq 400
      json_response = JSON.parse response.body
      expect(json_response['success']).to be false
      expect(json_response['message']).to eq 'Please provide a numeric UID.'
    end

    it 'should return success_response on valid uid' do
      User::StoredUsers.should_receive(:store_recent_uid).with(session_user_id, '100').and_return success_response

      post :store_recent_uid, params: { format: 'json', uid: '100' }
      expect(response).to be_successful
      json_response = JSON.parse response.body
      expect(json_response['success']).to be true
    end
  end

  describe '#delete_saved_uid' do
    it 'should return error_response on invalid uid' do
      post :delete_saved_uid, params: { format: 'json', uid: 'not_numeric' }
      expect(response.status).to eq 400
      json_response = JSON.parse response.body
      expect(json_response['success']).to be false
      expect(json_response['message']).to eq 'Please provide a numeric UID.'
    end

    it 'should return success_response on valid uid' do
      User::StoredUsers.should_receive(:delete_saved_uid).with(session_user_id, '100').and_return success_response

      post :delete_saved_uid, params: { format: 'json', uid: '100' }
      expect(response).to be_successful
      json_response = JSON.parse response.body
      expect(json_response['success']).to be true
    end
  end

  describe '#delete_all_recent' do
    it 'should return success_response' do
      User::StoredUsers.should_receive(:delete_all_recent).with(session_user_id).and_return success_response

      post :delete_all_recent, params: { format: 'json' }
      expect(response).to be_successful
      json_response = JSON.parse response.body
      expect(json_response['success']).to be true
    end
  end

  describe '#delete_all_saved' do
    it 'should return success_response' do
      User::StoredUsers.should_receive(:delete_all_saved).with(session_user_id).and_return success_response

      post :delete_all_saved, params: { format: 'json' }
      expect(response).to be_successful
      json_response = JSON.parse response.body
      expect(json_response['success']).to be true
    end
  end

end
