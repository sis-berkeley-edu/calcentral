describe CampusSolutions::EthnicityDelete do

  let(:user_id) { '12346' }

  context 'deleting ethnicity' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::EthnicityDelete.new(fake: true, user_id: user_id, params: params) }

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        bogus: 'foo',
        regRegion: 'USA',
        ethnicGroupCode: 'ASIANIND'
      } }
      subject {
        proxy.construct_cs_post(params)
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject[:query][:REG_REGION]).to eq 'USA'
        expect(subject[:query][:ETHNIC_GRP_CD]).to eq 'ASIANIND'
        expect(subject[:query].keys.length).to eq 3
      end
    end

    context 'performing a delete' do
      let(:params) { {
        regRegion: 'USA',
        ethnicGroupCode: 'ASIANIND'
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
