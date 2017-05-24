describe LinkFetcher do

  class TestLinkFetcher
    extend LinkFetcher
  end

  before do
    allow(proxy_class).to receive(:new).and_return mock_proxy
    allow(mock_proxy).to receive(:get_url).and_return(proxy_response)
    allow(TestLinkFetcher).to receive(:logger).and_return ClassLogger::LogWrapper.new('TestLinkFetcher')
  end
  let(:proxy_response) do
    {
      link: {
        url: url
      }
    }
  end
  let(:url) { 'fake url foo={foo}' }
  let(:placeholders) { {foo: 'bar'} }
  let(:proxy_class) { CampusSolutions::Link }
  let(:mock_proxy) { proxy_class.new(fake: true) }

  shared_examples 'a model that fetches a link' do
    it 'calls proxy with appropriate arguments and returns url' do
      expect(mock_proxy).to receive(:get_url).with(link_key)
      expect(output).to eq url
    end
  end
  shared_examples 'an obedient link fetcher' do
    context 'when proxy returns malformed proxy_response' do
      let(:link_key) { 123 }
      let(:proxy_response) { 'bad response' }
      it 'calls proxy with appropriate arguments and logs an error' do
        expect(mock_proxy).to receive(:get_url).with(link_key)
        expect(Rails.logger).to receive(:send).with(:debug, "[TestLinkFetcher] Could not parse CS link response for id #{link_key}, params: {:foo=>\"bar\"}")
        expect(subject).to eq bad_output
      end
    end
    context 'when proxy returns expected response' do
      context 'when parameters are not provided' do
        let(:placeholders) { nil }
        context 'when key is blank' do
          let(:link_key) { nil }
          it_behaves_like 'a model that fetches a link'
        end
        context 'when key is present' do
          let(:link_key) { 'gimme a link' }
          it_behaves_like 'a model that fetches a link'
        end
      end
      context 'when parameters are provided' do
        let(:link_key) { 'gimme a link' }
        it 'calls proxy with appropriate arguments and replaces placeholders with parameters' do
          expect(mock_proxy).to receive(:get_url).with(link_key)
          expect(output).to eq 'fake url foo=bar'
        end
        context 'when invalid parameters are provided they are ignored' do
          let(:placeholders) { {foo: nil} }
          it_behaves_like 'a model that fetches a link'
        end
      end
    end
  end

  describe '#fetch_link' do
    subject { TestLinkFetcher.fetch_link(link_key, placeholders) }
    let(:bad_output) { nil }
    let(:output) { subject[:url] }
    it_behaves_like 'an obedient link fetcher'
  end

  describe '#link_feed' do
    subject { TestLinkFetcher.link_feed(link_key, placeholders) }
    let(:bad_output) { proxy_response }
    let(:output) { subject[:link][:url] }
    it_behaves_like 'an obedient link fetcher'
  end
end
