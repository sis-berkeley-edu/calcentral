describe CampusSolutions::LinkController do
  context 'link feed' do
    let(:feed) { :get }

    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:user_id) { '12345' }
      let(:feed_key) { 'link' }
      let(:url_id) { "UC_CX_APPOINTMENT_ADV_SETUP" }

      let(:placeholder_empl_id) { "Some placeholder text" }
      let(:placeholders) { {:EMPLID => placeholder_empl_id, :IGNORED_PLACEHOLDER => "not used"} }

      before { session['user_id'] = user_id }

      it 'returns empty feed when urlId param not specified' do
        get feed, as: :json
        expect(response.status).to eq 200

        json_response = JSON.parse(response.body)
        expect(json_response["link"]).to_not be
      end

      it 'returns link feed with matching urlId' do
        get feed, params: {:urlId => url_id }, as: :json
        expect(response.status).to eq 200

        json_response = JSON.parse(response.body)
        expect(json_response["link"]["urlId"]).to eq url_id
        # Verify placeholder text is not replaced when placeholders params are omitted.
        expect(json_response["link"]["url"]).to include("EMPLID={EMPLID}")
      end

      it 'returns link feed with matching urlId and replaced "placeholder[name]" values' do
        get feed, params: {:urlId => url_id, :placeholders => placeholders }, as: :json
        expect(response.status).to eq 200

        json_response = JSON.parse(response.body)
        expect(json_response["link"]["urlId"]).to eq url_id
        expect(json_response["link"]["properties"]).not_to be
        # Verify placeholder is replaced by placeholders param entry.
        expect(json_response["link"]["url"]).to include("EMPLID=#{placeholder_empl_id}")
      end

    end
  end
end
