describe CampusSolutions::FppEnrollmentController do

  let(:user_id) { '12345' }

  context 'FPP Enrollment feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:feed_path) { ['feed','ucSfFppEnroll'] }
      it_behaves_like 'a successful feed'
      it 'has some field mapping info' do
        session['user_id'] = user_id
        get feed
        json = JSON.parse(response.body)
        expect(json['feed']['ucSfFppEnroll']['fppEnrollUrl']['isCsLink']).to eq(true)
        expect(json['feed']['ucSfFppEnroll']['fppEnrollUrl']['name']).to eq("Activate Fee Payment Plan")
        expect(json['feed']['ucSfFppEnroll']['fppEnrollUrl']['url']).to eq("https://bcs-web-dev-02.is.berkeley.edu:8443/psc/bcscfg/EMPLOYEE/HRMS/c/SA_LEARNER_SERVICES.SSF_SS_PPL_ENRL.GBL")
      end
    end
  end

end
