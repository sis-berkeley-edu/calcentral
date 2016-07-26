describe CampusSolutions::EnrollmentTermController do

  let(:user_id) { '12345' }
  before do
    allow(Settings.features).to receive(:cs_enrollment_card).and_return true
    allow_any_instance_of(HubEdos::UserAttributes).to receive(:has_role?).with(:student).and_return true
  end

  context 'enrollment term feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:feed_key) { 'enrollmentTerm' }
      it_behaves_like 'a successful feed'
      it 'has some term data' do
        session['user_id'] = user_id
        get feed, {term_id: '2162', format: 'json'}
        json = JSON.parse response.body
        expect(json['feed']['enrollmentTerm']['termDescr']).to eq 'Spring 2016'
      end
    end
  end

end
