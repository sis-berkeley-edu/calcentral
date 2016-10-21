describe CampusSolutions::DegreeProgressController do

  context '#get' do
    let(:feed) { :get }

    before do
      allow_any_instance_of(AuthenticationStatePolicy).to receive(:graduate_student?).and_return(true)
    end

    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:user_id) { '12345' }
      let(:feed_key) { 'degreeProgress' }

      it_behaves_like 'a successful feed'
    end
  end
end
