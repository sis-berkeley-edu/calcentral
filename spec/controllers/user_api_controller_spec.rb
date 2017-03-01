describe UserApiController do
  let (:user_id) { random_id }
  before do
    session['user_id'] = user_id
    allow(CampusOracle::UserAttributes).to receive(:new).with(user_id: user_id).and_return(double(get_feed: {
      'person_name' => 'Joe Test',
      :roles => {
        :student => true,
        :faculty => false,
        :staff => false
      }
    }))
    allow(Settings.features).to receive(:reauthentication).and_return(false)
  end

  context 'when not logged in' do
    let(:user_id) { nil }
    it 'should not have a logged-in status' do
      get :mystatus
      assert_response :success
      json_response = JSON.parse(response.body)
      json_response['isLoggedIn'].should == false
      json_response['uid'].should be_nil
      json_response['features'].should_not be_nil
    end
  end

  context 'when a known real user' do
    let(:user_id) { '238382' }
    it 'should show status' do
      get :mystatus
      json_response = JSON.parse(response.body)
      expect(json_response['isLoggedIn']).to be_truthy
      expect(json_response['uid']).to eq user_id
      expect(json_response['preferredName']).to be_present
      expect(json_response['features']).to be_present
      expect(json_response['isDirectlyAuthenticated']).to be true
      expect(json_response['canActOnFinances']).to be true
      visit = User::Visit.where(:uid => session['user_id'])[0]
      expect(visit.last_visit_at).to be_present
    end
    context 'in LTI' do
      let(:uid) { user_id }
      include_context 'LTI authenticated'
      it 'succeeds' do
        get :mystatus
        json_response = JSON.parse(response.body)
        expect(json_response['isLoggedIn']).to be_truthy
        expect(json_response['uid']).to eq user_id
        expect(json_response['preferredName']).to be_present
        expect(json_response['features']).to be_present
        expect(json_response['isDirectlyAuthenticated']).to be false
      end
    end
  end

  context 'when a new user' do
    it 'should record the first login' do
      get :mystatus
      json_response = JSON.parse(response.body)
      expect(json_response['firstLoginAt']).to be_nil
      get :record_first_login
      expect(response.status).to eq 204
      get :mystatus
      json_response = JSON.parse(response.body)
      expect(json_response['firstLoginAt']).to be_present
    end
  end

  describe '#acting_as_uid' do
    subject do
      get :mystatus
      JSON.parse(response.body)['actingAsUid']
    end
    context 'when normally authenticated' do
      it { should be false }
    end
    context 'when viewing as' do
      let(:original_user_id) { random_id }
      before { session[SessionKey.original_user_id] = original_user_id }
      it { should eq original_user_id }
    end
    context 'when authenticated by LTI' do
      before { session['lti_authenticated_only'] = true }
      it { should eq 'Authenticated through LTI' }
    end
    context 'when masquerading through LTI' do
      let(:canvas_user_id) {random_id}
      before do
        session['lti_authenticated_only'] = true
        session['canvas_masquerading_user_id'] = canvas_user_id
      end
      it { should eq "Authenticated through LTI: masquerading Canvas ID #{canvas_user_id}" }
    end
  end

  describe '#delegate_acting_as_uid' do
    subject do
      get :mystatus
      JSON.parse response.body
    end
    context 'normally authenticated' do
      it 'should deliver user\'s preferred and given names' do
        expect(subject['delegateActingAsUid']).to be false
        expect(subject['preferredName']).to_not be_nil
        expect(subject['firstName']).to_not eq subject['givenFirstName']
        expect(subject['fullName']).to_not eq subject['givenFullName']
        expect(subject['preferredName']).to_not eq subject['givenFullName']
      end
    end
    context 'viewing as' do
      let(:original_delegate_user_id) { random_id }
      before do
        session[SessionKey.original_delegate_user_id] = original_delegate_user_id
        # Give student superpowers with the hope that delegate user has powers turned off.
        allow(User::Auth).to receive(:get) do |uid|
          case uid
            when user_id
              double(is_superuser?: true, is_viewer?: true, active?: true)
            else
              double(is_superuser?: false, is_viewer?: false, active?: true)
          end
        end
      end
      it 'should identify user in delegate-view-as mode' do
        expect(subject['delegateActingAsUid']).to eq original_delegate_user_id
        expect(subject['isDirectlyAuthenticated']).to be false
      end
      it 'should remove preferred name and other sensitive during delegate-view-as mode' do
        expect(subject['delegateActingAsUid']).to eq original_delegate_user_id
        expect(subject['firstLoginAt']).to be_nil
        expect(subject['firstName']).to eq subject['givenFirstName']
        expect(subject['fullName']).to eq subject['givenFullName']
        expect(subject['preferredName']).to eq subject['givenFullName']
        expect(subject['isDelegateUser']).to be false
        expect(subject['isViewer']).to be false
        expect(subject['isSuperuser']).to be false
      end
    end
  end

  describe '#advisor_acting_as_uid' do
    subject do
      get :mystatus
      JSON.parse response.body
    end
    context 'viewing as' do
      let(:original_advisor_user_id) { random_id }
      before do
        session[SessionKey.original_advisor_user_id] = original_advisor_user_id
        allow(User::Auth).to receive(:get) do |uid|
          case uid
            when user_id
              double(is_superuser?: true, is_viewer?: true, active?: true)
            else
              double(is_superuser?: false, is_viewer?: false, active?: true)
          end
        end
      end
      it 'should identify user in advisor-view-as mode' do
        expect(subject['advisorActingAsUid']).to eq original_advisor_user_id
        expect(subject['isDirectlyAuthenticated']).to be false
        expect(subject['canActOnFinances']).to be false
      end
    end
  end

  describe 'superuser status' do
    before do
      session[SessionKey.original_user_id] = original_user_id
      allow(User::Auth).to receive(:get) do |uid|
        case uid
          when user_id
            double(is_superuser?: true, is_viewer?: false, active?: true)
          when original_user_id
            double(is_superuser?: false, is_viewer?: true, active?: true)
        end
      end
    end
    context 'getting status as a superuser' do
      subject do
        get :mystatus
        JSON.parse(response.body)['isSuperuser']
      end
      context 'when normally authenticated' do
        let(:original_user_id) { nil }
        it { should be_truthy }
      end
      context 'when viewing as' do
        let(:original_user_id) { random_id }
        it { should be_falsey }
      end
      context 'when authenticated by LTI' do
        let(:original_user_id) { nil }
        before { session['lti_authenticated_only'] = true }
        it { should be_falsey }
      end
    end

    context 'altering another users data as a superuser should not be possible' do

      context 'recording first login' do
        subject do
          before { User::Api.should_not_receive(:from_session) }
          get :record_first_login
          context 'when viewing as' do
            let(:original_user_id) { random_id }
            expect(response.status).to eq 204
          end
          context 'when authenticated by LTI' do
            let(:original_user_id) { nil }
            before { session['lti_authenticated_only'] = true }
            it { should eq 403 }
          end
        end
      end

      context 'when viewing as' do
        subject do
          get :mystatus
          JSON.parse response.body
        end
        let(:original_user_id) { random_id }
        it 'does not allow changing financial data' do
          expect(subject['isDirectlyAuthenticated']).to be false
          expect(subject['canActOnFinances']).to be false
        end
      end
    end
  end

end
