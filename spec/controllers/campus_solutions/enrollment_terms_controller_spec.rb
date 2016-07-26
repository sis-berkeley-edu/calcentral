describe CampusSolutions::EnrollmentTermsController do

  let(:user_id) { '12345' }
  before do
    allow(Settings.features).to receive(:cs_enrollment_card).and_return true
    allow_any_instance_of(HubEdos::UserAttributes).to receive(:has_role?).with(:student).and_return true
  end

  context 'enrollment terms feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:feed_key) { 'enrollmentTerms' }
      it_behaves_like 'a successful feed'
      it 'has some field mapping info' do
        session['user_id'] = user_id
        get feed
        json = JSON.parse(response.body)
        expect(json['feed']['enrollmentTerms'][0]['termId']).to eq '2162'
      end
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
      it 'allows access' do
        get :get
        assert_response :success
        json_response = JSON.parse(response.body)
        json_response.should be_present
      end
    end
    context 'financial access' do
      let(:privileges) do
        {
          financial: true
        }
      end
      it 'denies all access' do
        get :get
        expect(response.status).to eq 403
        expect(response.body).to eq ' '
      end
    end
  end

end
