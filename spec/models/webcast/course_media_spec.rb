describe Webcast::CourseMedia do

  context 'when generating id according to year, term, ccn' do
    it 'should allow lookups by either term_cd or term name' do
      expect(Webcast::CourseMedia.id_per_ccn(2014, 'sPriNg ', 1234)).to eq '2014-B-1234'
      expect(Webcast::CourseMedia.id_per_ccn(2014, 'd', 1234)).to eq '2014-D-1234'
      expect(Webcast::CourseMedia.id_per_ccn(2014, 'summer', 1234)).to eq '2014-C-1234'
      expect(Webcast::CourseMedia.id_per_ccn(2014, ' C', 1234)).to eq '2014-C-1234'
    end
  end

  context 'when Webcast hits proxy error' do
    subject { Webcast::CourseMedia.new(2008, 'D', [49688], fake: true) }

    context 'when proxy error message is not blank' do
      before do
        proxy_error_hash = {proxyErrorMessage: 'Proxy Error'}
        expect(subject).to receive(:get_media_hash).and_return proxy_error_hash
      end
      it 'should return the proxy error message' do
        response = subject.get_feed
        expect(response[:proxyErrorMessage]).to eq 'Proxy Error'
      end
    end

    context 'when video feature flag is false' do
      before { allow(Settings.features).to receive(:videos).and_return false }
      it 'should return empty array' do
        expect(subject.get_feed).to be_empty
      end
    end
  end

  context 'when serving a single set of Webcast recordings' do
    subject { Webcast::CourseMedia.new(2008, 'D', [49688], fake: true) }

    context 'when proxy error message is blank' do
      it 'should parse Webcast JSON per normal procedure' do
        response = subject.get_feed[49688]
        expect(response).not_to be_nil
        expect(response[:youTubePlaylist]).to eq 'EC8DA9DAD111EAAD28'
        expect(response[:videos]).to have(12).items
        expect(response[:videos][0]['youTubeId']).to eq 'bBithUtaaas'
      end
    end
  end

  context 'when serving multiple sets of Webcast recordings' do
    context 'when ccn matches a set of Webcast recordings' do
      subject { Webcast::CourseMedia.new(2014, 'B', [1, 87432, 2, 76207], fake: true) }
      it 'should return youtube videos' do
        response = subject.get_feed
        expect(response[1]).to be_nil
        expect(response[87432][:videos]).to have(31).items
        expect(response[2]).to be_nil
        expect(response[76207][:videos]).to have(35).items
      end
    end

    context 'when videos are not present' do
      subject { Webcast::CourseMedia.new(2014, 'D', [123], fake: true) }
      it 'should return an empty array' do
        response = subject.get_feed[123]
        expect(response[:videos]).to be_empty
      end
    end

    context 'when course title has a _slash_' do
      subject { Webcast::CourseMedia.new(2014, 'D', [85006], fake: true) }
      it 'should decode _slash_ to /' do
        expect(subject.get_feed[85006]).to be_an_instance_of Hash
      end
    end
  end

  context 'with non-fake proxy', testext: true do
    context 'when serving multiple sets of Webcast recordings' do
      let (:playlist_uri) { URI.parse "#{Settings.webcast_proxy.base_url}/warehouse/webcast.json" }
      subject { Webcast::CourseMedia.new(2014, 'B', [7502, 11147, 1]) }

      context 'normal return of real data' do
        it 'should return correct recordings' do
          result = subject.get_feed[11147]
          expect(result[:videos]).to be_an_instance_of Array
          expect(result[:videos].size).to eq 14
          recording = result[:videos][0]
          expect(recording).to be_an_instance_of Hash
          expect(recording['youTubeId']).to eq 'mYZS-y6RuGI'
          expect(recording['lecture']).to eq '2014-05-02: Review for Final Exam'
          expect(recording['recordingStartUTC']).to eq '2014-05-02T12:07:00-07:00'
        end
      end

      context 'on remote server errors' do
        before(:each) {
          stub_request(:any, /.*#{playlist_uri.hostname}.*/).to_return(status: 506)
        }
        after(:each) { WebMock.reset! }
        it 'should return the fetch error message' do
          expect(subject.get_feed).to be_empty
        end
      end

      context 'when json formatting fails' do
        before(:each) {
          stub_request(:any, /.*#{playlist_uri.hostname}.*/).to_return(status: 200, body: 'bogus json')
        }
        after(:each) { WebMock.reset! }
        it 'should return the fetch error message' do
          expect(subject.get_feed).to be_empty
        end
      end

      context 'when video feature flag is false' do
        before { allow(Settings.features).to receive(:videos).and_return false }
        it 'should return an empty hash' do
          expect(subject.get_feed).to be_empty
        end
      end
    end
  end
end
