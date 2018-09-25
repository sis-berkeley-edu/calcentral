describe CampusSolutions::EmergencyPhone do
  let(:user_id) { '12345' }

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::EmergencyPhone.new(fake: true, user_id: user_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        contactName: 'Joe'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 5
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:contactName]).to eq 'Joe'
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        contactName: 'Joe',
        phoneType: 'HOME',
        phone: '123-123-1234',
        extension: '123',
        countryCode: ''
      } }
      subject {
        result = proxy.construct_cs_post(params)
        MultiXml.parse(result)['UC_EMER_PHONE']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['PHONE_TYPE']).to eq 'HOME'
        expect(subject['CONTACT_NAME']).to eq 'Joe'
        expect(subject['COUNTRY_CODE']).to be_falsey
      end
    end

    context 'performing a post' do
      let(:params) { {
        contactName: 'Joe',
        phoneType: 'HOME',
        phone: '123-123-1234',
        extension: '123',
        countryCode: ''
      } }
      subject {
        proxy.get
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it_behaves_like 'a proxy that properly observes the profile feature flag'
      it_behaves_like 'a proxy that got data successfully'
    end

  end
end
