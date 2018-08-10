# encoding: UTF-8
describe CampusSolutions::Address do

  let(:user_id) { '12345' }

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::Address.new(fake: true, user_id: user_id, params: params) }

    context 'when given params not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        address1: '1 Test Lane'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should filter out the invalid params' do
        expect(subject.keys.length).to eq 16
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:address1]).to eq '1 Test Lane'
      end
    end

    context 'when converting params to Campus Solutions field names' do
      let(:params) { {
        addressType: 'HOME',
        address1: '1 Test Lane'
      } }
      subject {
        result = proxy.construct_cs_post(params)
        MultiXml.parse(result)['UC_CC_ADDR_UPD_REQ']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['ADDRESS1']).to eq '1 Test Lane'
        expect(subject['ADDRESS_TYPE']).to eq 'HOME'
      end
    end

    context 'when posting a param with invalid values' do
      let(:params) { {
        addressType: 'DORM',
        address1: '1 Test Lane'
      } }
      subject {
        proxy.post
      }
      it 'raises an error and aborts' do
        expect{
          subject
        }.to raise_error Errors::BadRequestError, /Invalid request: {:addressType=>"DORM", :address1=>"1 Test Lane"}/
        expect(CampusSolutions::Proxy).to receive(:get).never
      end
    end

    context 'when posting valid params' do
      let(:params) { {
        addressType: 'HOME',
        address1: '1 Test Lane'
      } }
      subject {
        proxy.post
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it_behaves_like 'a proxy that properly observes the profile feature flag'
      it_behaves_like 'a proxy that got data successfully'
    end
  end
end
