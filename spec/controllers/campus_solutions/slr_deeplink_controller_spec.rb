describe CampusSolutions::SlrDeeplinkController do

  let(:user_id) { '12345' }

  context 'SLR feed' do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:feed_path) { ['feed','root'] }
      it_behaves_like 'a successful feed'
      it 'has some field mapping info' do
        session['user_id'] = user_id
        get feed
        json = JSON.parse(response.body)
        expect(json['feed']['root']['ucSrSlrResources']['ucSlrLinks']['ucSlrLink']['isCsLink']).to eq(true)
        expect(json['feed']['root']['ucSrSlrResources']['ucSlrLinks']['ucSlrLink']['name']).to eq("SLR_LINK")
        expect(json['feed']['root']['ucSrSlrResources']['ucSlrLinks']['ucSlrLink']['url']).to eq("https://bcs-web-dev-03.is.berkeley.edu:8443/psc/bcsdev/EMPLOYEE/HRMS/c/UC_SR_SLR.UC_SLR_STDNT.GBL")
      end
    end
  end

end
