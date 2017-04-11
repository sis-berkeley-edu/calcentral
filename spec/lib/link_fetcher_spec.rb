describe LinkFetcher do

  describe '#fetch_link' do
    before do
      allow(proxy_class).to receive(:new).and_return mock_proxy
      link_fetcher.extend(LinkFetcher)
      allow(link_fetcher).to receive(:logger).and_return ClassLogger::LogWrapper.new('Object')
    end
    let(:link_fetcher) { Object.new }
    let(:url) { 'fake url' }
    let(:proxy_class) { CampusSolutions::Link }
    let(:mock_proxy) { proxy_class.new(fake: true) }

    context 'when proxy returns malformed response' do
      before do
        allow(mock_proxy).to receive(:get_url).and_return('bad response')
      end
      subject do
        link_fetcher.fetch_link(link_key)
      end
      let(:link_key) { nil }

      it 'calls the proxy with appropriate arguments and logs an error' do
        expect(mock_proxy).to receive(:get_url).with(nil, {})
        expect(Rails.logger).to receive(:send).with(:debug, /\[Object\] Could not parse CS link response for id/)
        expect(subject).to eq nil
      end
    end

    context 'when proxy returns expected response' do
      before do
        allow(mock_proxy).to receive(:get_url).and_return({link: url})
      end

      context 'when parameters are not provided' do
        subject do
          link_fetcher.fetch_link(link_key)
        end

        context 'when key is blank' do
          let(:link_key) { nil }

          it 'calls the proxy with appropriate arguments and returns url' do
            expect(mock_proxy).to receive(:get_url).with(nil, {})
            expect(subject).to eq url
          end
        end
        context 'when key is present'
        let(:link_key) { 'gimme a link' }

        it 'calls the proxy with appropriate arguments and returns url' do
          expect(mock_proxy).to receive(:get_url).with('gimme a link', {})
          expect(subject).to eq url
        end
      end

      context 'when parameters are provided' do
        subject do
          link_fetcher.fetch_link(link_key, placeholders)
        end
        let(:link_key) { nil }
        let(:placeholders) { 'some params' }

        it 'calls the proxy with appropriate arguments and returns url' do
          expect(mock_proxy).to receive(:get_url).with(nil, 'some params')
          expect(subject).to eq url
        end
      end
    end
  end
end
