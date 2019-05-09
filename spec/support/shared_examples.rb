###############################################################################################
# Shared Examples
# ---------------
#
# Used to provide test functionality that is shared across tests.
# See https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples
#
###############################################################################################

# This example is intended to be used with let(:make_request) which defines the controller method call
# for the method that is being tested. For example, see spec/controllers/my_academics_controller_spec.rb
shared_examples 'a user authenticated api endpoint' do
  context 'when no user session present' do
    before { session['user_id'] = nil }
    it 'returns empty json hash' do
      make_request
      assert_response :success
      json_response = JSON.parse(response.body)
      json_response.should == {}
    end
  end
end

shared_examples 'an authenticated endpoint' do
  context 'when no user session present' do
    before { session['user_id'] = nil }
    it 'returns empty response' do
      make_request
      expect(response.status).to eq(401)
      expect(response.body).to eq ''
    end
  end
end

shared_examples 'an unauthorized endpoint for delegates' do
  before do
    session['user_id'] = random_id
    session[SessionKey.original_delegate_user_id] = random_id
  end
  it 'denies all access' do
    make_request
    expect(response.status).to eq 403
    expect(response.body).to eq ''
  end
end

shared_examples 'an unauthorized endpoint for users in advisor-view-as mode' do
  before do
    session['user_id'] = random_id unless session['user_id']
    session[SessionKey.original_advisor_user_id] = random_id
  end
  it 'denies all access' do
    make_request
    # Controller might rescue_from authorization failure then return 500 status
    expect(response.status).to be >= 403
    expect(response.body.blank? || JSON.parse(response.body)['error']).to be_truthy
  end
end

shared_examples 'an unauthorized endpoint for LTI' do
  before do
    session['user_id'] = random_id
    session[SessionKey.lti_authenticated_only] = true
  end
  it 'denies all access' do
    make_request
    expect(response.status).to eq 403
    expect(response.body).to eq ''
  end
end

shared_examples 'an api endpoint' do
  context 'when standarderror exception raised' do
    it 'returns json formatted 500 error' do
      make_request
      expect(response.status).to eq(500)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to be_an_instance_of String
      expect(json_response['error']).to eq 'Something went wrong'
    end
  end
end

shared_examples 'an endpoint' do
  context 'when standarderror exception raised' do
    it 'returns 500 error' do
      make_request
      expect(response.status).to eq(500)
      expect(response.body).to eq error_text
    end
  end
end

shared_examples 'a cross-domain endpoint' do
  it 'sets cross origin access control headers' do
    make_request
    expect(response.headers).to be_an_instance_of Hash
    expect(response.headers['Access-Control-Allow-Origin']).to eq Settings.canvas_proxy.url_root
    expect(response.header['Access-Control-Allow-Methods']).to eq 'GET, OPTIONS, HEAD'
    expect(response.header["Access-Control-Max-Age"]).to eq '86400'
  end
end

# Needs the following variables defined: uid, campus_solutions_id, privileges
shared_context 'delegated access' do
  before do
    session['user_id'] = uid
    original_uid = random_id
    session[SessionKey.original_delegate_user_id] = original_uid
    allow(CampusSolutions::DelegateStudents).to receive(:new).and_return (cs_proxy = double)
    allow(cs_proxy).to receive(:get).and_return(
      {
        feed: {
          students: [
            {
              uid: uid,
              campusSolutionsId: campus_solutions_id,
              privileges: privileges
            }
          ]
        }
      }
    )
    allow(Settings.features).to receive(:cs_delegated_access).and_return true
  end
end

shared_context 'advisor view-as' do
  before do
    allow(Settings.features).to receive(:reauthentication).and_return false
    session['user_id'] = uid
    session[SessionKey.original_advisor_user_id] = random_id
  end
end

shared_context 'LTI authenticated' do
  before do
    session['user_id'] = uid
    session[SessionKey.lti_authenticated_only] = true
  end
end
