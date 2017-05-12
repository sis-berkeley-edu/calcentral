describe MyAcademicRecordsController do
  let(:feed_key) { 'feed' }

  before do
    allow(MyAcademics::AcademicRecords).to receive(:from_session).and_return double get_feed_as_json: { feed: MyAcademics::AcademicRecords.name }
  end

  describe '#get_feed' do
    let(:make_request) { get :get_feed }
    it_behaves_like 'a user authenticated api endpoint'

    context 'when authenticated user exists' do
      let(:uid) { '12345' }
      subject { make_request }

      context 'normal user session' do
        it 'should return a feed' do
          session['user_id'] = uid
          json = JSON.parse subject.body
          expect(json[feed_key]).to eq MyAcademics::AcademicRecords.name
        end
      end
    end
  end
end
