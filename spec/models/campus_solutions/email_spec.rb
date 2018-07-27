describe CampusSolutions::Email do

  let(:user_id) { '12345' }

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::Email.new(fake: true, user_id: user_id, params: params) }

    context 'when given params not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        email: 'foo@foo.com'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 3
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:email]).to eq 'foo@foo.com'
        expect(subject[:type]).to eq ''
      end
    end

    context 'when converting params to Campus Solutions field names' do
      let(:params) { {
        type: 'HOME',
        email: 'foo@foo.com'
      } }
      subject {
        result = proxy.construct_cs_post(params)
        MultiXml.parse(result)['EMAIL_ADDRESS']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['E_ADDR_TYPE']).to eq 'HOME'
        expect(subject['EMAIL_ADDR']).to eq 'foo@foo.com'
      end
    end

    context 'when posting a param with an invalid value' do
      let(:params) { {
        type: 'CAMP',
        email: 'foo@foo.com',
        isPreferred: 'N'
      } }
      subject {
        proxy.post
      }
      it 'raises an error and aborts' do
        expect{
          subject
        }.to raise_error Errors::BadRequestError, /Invalid request: {:type=>"CAMP", :email=>"foo@foo.com", :isPreferred=>"N"}/
        expect(CampusSolutions::Proxy).to receive(:get).never
      end
    end

    context 'when posting valid params' do
      let(:params) { {
        type: 'HOME',
        email: 'foo@foo.com',
        isPreferred: 'N'
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
