describe CampusSolutions::HigherOneUrlController do

  let(:user_id) { '12349' }
  let(:higher_one_url) { 'https://commerce.cashnet.com/UCBpaytest?eusername=8062064084e9a8dff7a181266a3ed11e28b80eb30ab4fd84b9bc4de92394d884' }

  context 'higher one url feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:feed_key) { 'root' }
      it_behaves_like 'a successful feed'
      it 'has some field mapping info' do
        session['user_id'] = user_id
        get feed
        json = JSON.parse(response.body)
        expect(json['feed']['root']['higherOneUrl']['url'].strip).to eq higher_one_url
      end
    end
  end

  context 'redirect as a student' do
    before do
      session['user_id'] = user_id
    end
    it 'redirects to higher one' do
      get :redirect
      expect(response.status).to eq 302
      expect(response).to redirect_to higher_one_url
    end
  end

  context 'classic view-as' do
    before do
      session['user_id'] = user_id
      session[SessionKey.original_user_id] = random_id
      allow(CalnetCrosswalk::ByUid).to receive(:new).and_return (crosswalk = double)
      allow(crosswalk).to receive(:lookup_campus_solutions_id).and_return random_id
      expect(Settings.features).to receive(:reauthentication).and_return false
    end
    it 'denies all access' do
      get :get
      expect(response.status).to eq 403
      expect(response.body).to eq ''
    end
  end

  context 'delegated access' do
    let(:uid) {random_id}
    let(:campus_solutions_id) {random_id}
    include_context 'delegated access'
    context 'enrollments-only access' do
      let(:privileges) do
        {
          viewEnrollments: true
        }
      end
      it 'denies all access' do
        get :get
        expect(response.status).to eq 403
        expect(response.body).to eq ''
      end
    end
    context 'financial access' do
      let(:privileges) do
        {
          financial: true
        }
      end
      it 'allows access' do
        get :get
        assert_response :success
        json_response = JSON.parse(response.body)
        json_response.should be_present
      end
      it 'redirects to higher one' do
        get :redirect
        expect(response.status).to eq 302
        expect(response).to redirect_to higher_one_url
      end
    end
  end


end
