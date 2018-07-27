describe CampusSolutions::LanguageDelete do

  let(:user_id) { '12346' }

  context 'deleting language' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::LanguageDelete.new(fake: true, user_id: user_id, params: params) }

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        bogus: 'foo',
        languageCode: 'LEN'
      } }
      subject {
        proxy.construct_cs_post(params)
      }
      it 'should convert languageCode param to JPM_CAT_ITEM_ID' do
        expect(subject[:query][:JPM_CAT_ITEM_ID]).to eq 'LEN'
      end
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject[:query].keys.length).to eq 2
      end
    end

    context 'performing a delete' do
      let(:params) { {
        languageCode: 'LEN'
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
