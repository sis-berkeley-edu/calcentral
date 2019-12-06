describe MyHousingController do
  before do
    allow(FinancialAid::MyHousing).to receive(:from_session).and_return double get_feed_as_json: {feed: 'test' }
  end
  let(:user_id) { random_id }
  let(:params) do
    {
      aid_year: '2019'
    }
  end

  describe '#get_feed' do
    let(:make_request) { get :get_feed, params: params }
    it_behaves_like 'an authenticated endpoint'

    context 'when authenticated user exists' do
      let(:uid) { random_id }
      subject { make_request }

      context 'normal user session' do
        it 'should return a feed' do
          session['user_id'] = uid
          json = JSON.parse subject.body
          expect(json['feed']).to eq 'test'
        end
      end
      context 'when delegate is viewing a student' do
        include_context 'delegated access'
        let(:campus_solutions_id) {random_id}
        let(:privileges) do
          {
            financial: true
          }
        end
        it 'should return a feed' do
          session['user_id'] = uid
          json = JSON.parse subject.body
          expect(json['feed']).to eq 'test'
        end
      end
    end
  end
end
