describe CampusSolutions::Link do
  let(:proxy) { CampusSolutions::Link.new(fake: fake_proxy) }
  let(:url_id) { "UC_CX_APPOINTMENT_ADV_SETUP" }

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }

    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that got data successfully'
  end

  context 'mock proxy' do
    let(:fake_proxy) { true }

    let(:link_set_response) { proxy.get }
    let(:link_get_url_response) { proxy.get_url(url_id) }
    let(:link_get_url_with_bad_url_id_response) { proxy.get_url('BAD_URL_ID') }
    let(:link_get_url_for_properties_response) { proxy.get_url(url_id) }

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
      it 'returns a parsed response with the expected structure' do
        expect(link_get_url_response[:link]).not_to be
        expect(link_get_url_response[:status]).not_to be
      end
    end

    context 'returns an empty response' do
      let(:filename) { 'link_api_empty.xml' }

      it_should_behave_like 'a proxy that gets data'
      it 'returns data with the expected structure' do
        expect(link_set_response[:feed][:ucLinkResources]).not_to be
      end
      it 'returns a parsed response with the expected structure' do
        expect(link_get_url_response[:link]).not_to be
        expect(link_get_url_response[:status]).to eq 500
      end
    end

    context 'when returning links as an array' do
      context 'with multiple links' do
        let(:filename) { 'link_api_multiple.xml' }

        it_should_behave_like 'a proxy that gets data'
        it 'returns data with the expected structure' do
          expect(link_set_response[:feed][:ucLinkResources][:links].count).to be > 1
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

    context 'when returning a single link by its urlId' do
      let(:filename) { 'link_api_multiple.xml' }

      it_should_behave_like 'a proxy that gets data'
      it 'returns data with the expected structure' do
        expect(link_get_url_response[:link][:urlId]).to eq url_id
      end

      it 'replaces the properties hash with only certain properties' do
        expect(link_get_url_response[:link][:properties]).not_to be
        expect(link_get_url_for_properties_response[:link][:ucFrom]).to eq 'CalCentral'
        expect(link_get_url_for_properties_response[:link][:ucFromLink]).to eq 'https://calcentral-sis-dev-01.ist.berkeley.edu/'
        expect(link_get_url_for_properties_response[:link][:ucFromText]).to eq 'CalCentral'
        expect(link_get_url_for_properties_response[:link][:linkDescription]).to eq 'May your hats fly as high as your dreams'
        expect(link_get_url_for_properties_response[:link][:linkDescriptionDisplay]).to eq true
      end
    end

    context 'when no matching url_id' do
      let(:filename) { 'link_api.xml' }

      it_should_behave_like 'a proxy that gets data'
      it 'returns data with the expected structure' do
        expect(link_get_url_with_bad_url_id_response[:link]).not_to be
      end
    end
  end

  context 'real proxy', testext: true do
    let(:fake_proxy) { false }

    it_should_behave_like 'a proxy that gets data'
  end
end
