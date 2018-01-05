describe CampusSolutions::HigherOneUrl do

  let(:user_id) { '12349' }

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }

    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that got data successfully'

    it 'returns data with the expected structure' do
      expect(subject[:feed][:root][:higherOneUrl][:url]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::HigherOneUrl.new options }

    subject { proxy.get }

    context 'pass EMPLID arg to Campus Solutions' do
      let(:options) { { fake: true, user_id: user_id } }

      it_should_behave_like 'a proxy that gets data'

      it 'should get specific mock data' do
        expect(subject[:feed][:root][:higherOneUrl][:url].strip).to eq 'https://commerce.cashnet.com/UCBpaytest?eusername=8062064084e9a8dff7a181266a3ed11e28b80eb30ab4fd84b9bc4de92394d884'
        expect(proxy.url).to end_with '/UC_OB_HIGHER_ONE_URL_GET.v1/get?EMPLID=26662066'
      end
    end
    context 'pass both DELEGATE_UID and EMPLID args to Campus Solutions' do
      let(:delegate_uid) { '12350' }
      let(:options) { { fake: true, user_id: user_id, delegate_uid: delegate_uid } }

      it_should_behave_like 'a proxy that gets data'

      it 'should construct proper URL' do
        expect(proxy.url).to include("DELEGATE_UID=")
        expect(proxy.url).to include("EMPLID=")
      end
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::HigherOneUrl.new fake: false, user_id: user_id }

    it_should_behave_like 'a proxy that gets data'
  end

end
