describe CampusSolutions::LinkController do
  context 'link feed' do
    let(:feed) { :get }

    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:user_id) { '12345' }
      let(:feed_key) { 'link' }
      let(:url_id) { "UC_CX_TEST_LINK" }

      let(:placeholder_text) { "Some placeholder text" }
      let(:placeholders) { {:PLACEHOLDER => placeholder_text, :ANOTHER_PLACEHOLDER => "not used"} }

      before { session['user_id'] = user_id }

      it 'returns empty feed when urlId param not specified' do
        get feed, {:format => 'json'}
        expect(response.status).to eq 200

        json_response = JSON.parse(response.body)
        expect(json_response["feed"]["link"]).to_not be
      end

      it 'returns link feed with matching urlId' do
        get feed, {:urlId => url_id, :format => 'json'}
        expect(response.status).to eq 200

        json_response = JSON.parse(response.body)
        expect(json_response["feed"]["link"]["urlId"]).to eq url_id
        # Verify placeholder text is not replaced when placeholders params are omitted.
        expect(json_response["feed"]["link"]["url"]).to include("PLACEHOLDER={PLACEHOLDER}")
      end

      it 'returns link feed with matching urlId and replaced "placeholder[name]" values' do
        get feed, {:urlId => url_id, :placeholders => placeholders, :format => 'json'}
        expect(response.status).to eq 200

        json_response = JSON.parse(response.body)
        expect(json_response["feed"]["link"]["urlId"]).to eq url_id
        expect(json_response["feed"]["link"]["properties"].count).to eq 3
        # Verify placeholder is replaced by placeholders param entry.
        expect(json_response["feed"]["link"]["url"]).to include("PLACEHOLDER=#{placeholder_text}")
      end

    end
  end
end
