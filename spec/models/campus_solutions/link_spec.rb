describe CampusSolutions::Link do
  let(:proxy) { CampusSolutions::Link.new(fake: fake_proxy) }
  let(:url_id) { "UC_CX_TEST_LINK" }
  let(:placeholder_text) { "REPLACED_PLACEHOLDER" }

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }

    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that got data successfully'
  end

  context 'mock proxy' do
    let(:fake_proxy) { true }
    let(:link_set_response) { proxy.get }
    let(:link_get_url_response) { proxy.get_url(url_id) }

    let(:placeholders) { {:PLACEHOLDER => placeholder_text, :ANOTHER_PLACEHOLDER => "not used"} }
    let(:link_get_url_and_replace_placeholders_response) { proxy.get_url(url_id, placeholders) }

    before do
      allow_any_instance_of(CampusSolutions::Link).to receive(:xml_filename).and_return filename
    end

    context 'returns error message' do
      let(:filename) { 'link_api_error.xml' }

      it_should_behave_like 'a proxy that gets data'
      it 'returns data with the expected structure' do
        expect(link_set_response[:feed][:ucLinkResources][:isFault]).to eq "Y"
        expect(link_set_response[:feed][:ucLinkResources][:links]).not_to be
        expect(link_set_response[:feed][:ucLinkResources][:status][:details][:msgs][:msg][:messageSeverity]).to eq "E"
      end
    end

    context 'returns links as an array' do
      context 'with multiple links' do
        let(:filename) { 'link_api_multiple.xml' }

        it_should_behave_like 'a proxy that gets data'
        it 'returns data with the expected structure' do
          expect(link_set_response[:feed][:ucLinkResources][:links].count).to eq 3
        end
      end

      context 'with a single link' do
        let(:filename) { 'link_api.xml' }

        it_should_behave_like 'a proxy that gets data'
        it 'returns data with the expected structure' do
          expect(link_set_response[:feed][:ucLinkResources][:links].count).to eq 1
        end
      end
    end

    context 'returns a single link by its urlId' do
      let(:filename) { 'link_api.xml' }

      it_should_behave_like 'a proxy that gets data'
      it 'returns data with the expected structure' do
        expect(link_get_url_response[:feed][:link][:urlId]).to eq url_id
        expect(link_get_url_response[:feed][:link][:properties].count).to eq 3
        expect(link_get_url_response[:feed][:link][:show_new_window]).to eq true

        # Verify that {placeholder} text is present
        expect(link_get_url_response[:feed][:link][:url]).to include("PLACEHOLDER={PLACEHOLDER}")
      end

      context 'replaces any placeholders' do
        let(:filename) { 'link_api.xml' }

        it_should_behave_like 'a proxy that gets data'
        it 'returns data with the expected structure' do
          # Verify that {placeholder} text is replaced
          expect(link_get_url_and_replace_placeholders_response[:feed][:link][:url]).to include("PLACEHOLDER=#{placeholder_text}")
        end
      end
    end
  end

  context 'real proxy', testext: true do
    let(:fake_proxy) { false }

    it_should_behave_like 'a proxy that gets data'
  end
end
