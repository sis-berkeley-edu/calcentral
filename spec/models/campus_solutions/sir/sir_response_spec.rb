describe CampusSolutions::Sir::SirResponse do

  let(:user_id) { '12350' }
  let(:sir_statuses_feed) {
    {
      sirStatuses: [
        {
          itemStatusCode: 'I',
          chklstItemCd: 'AUSIRF',
          checkListMgmtAdmp: {
            admApplNbr: '00123456'
          }
        }
      ]
    }
  }


  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::Sir::SirResponse.new(fake: true, user_id: user_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        'bogus' => 1,
        'invalid' => 2,
        'studentCarNbr' => '1234'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields, and symbolize key names' do
        expect(subject.keys.length).to eq 9
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:studentCarNbr]).to eq '1234'
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        studentCarNbr: '1234'
      } }
      subject {
        result = proxy.construct_cs_post(params)
        MultiXml.parse(result)['UC_AD_SIR']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['STDNT_CAR_NBR']).to eq '1234'
      end
    end

    context 'performing a post' do
      let(:params) {
        {
        'admApplNbr' => '00123456',
        'chklstItemCd' => 'AUSIRF'
        }
      }
      before do
        CampusSolutions::Sir::SirStatuses.stub_chain(:new, :get_feed).and_return sir_statuses_feed
      end
      subject {
        proxy.post
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it_behaves_like 'a proxy that got data successfully'
    end

    context 'performing a post with altered parameters' do
      let(:params) {
        {
          'studentCarNbr' => '1234',
          'admApplNbr' => '00123456',
          'chklstItemCd' => 'AUSIRT'
        }
      }
      before do
        CampusSolutions::Sir::SirStatuses.stub_chain(:new, :get_feed).and_return sir_statuses_feed
      end
      subject { proxy.post }
      it 'catches mismatched parameters, raises an error and aborts' do
        expect{subject}.to raise_error(Errors::BadRequestError)
        expect(CampusSolutions::Proxy).to receive(:get).never
      end
    end
  end

  context 'with a real external service', testext: true do
    let(:proxy) { CampusSolutions::Sir::SirResponse.new(fake: false, user_id: user_id, params: params) }
    subject { proxy.post }

    context 'an invalid post' do
      let(:params) { {
        'studentCarNbr' => ''
      } }
      context 'performing a real but invalid post' do
        it_should_behave_like 'a simple proxy that returns errors'
        it_should_behave_like 'a proxy that responds to user error gracefully'
      end
    end
  end
end
