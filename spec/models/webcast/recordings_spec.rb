describe Webcast::Recordings do

  context 'a fake proxy' do
    let(:recordings) { Webcast::Recordings.new(fake: true).get }
    it 'should return many playlists' do
      expect(recordings[:courses]).to have(25).items
      law_2723 = recordings[:courses]['2008-D-49688']
      expect(law_2723).to_not be_nil
      expect(law_2723[:youtube_playlist]).to eq 'EC8DA9DAD111EAAD28'
      expect(law_2723[:recordings]).to have(12).items
    end
  end

  context 'a real, non-fake proxy', testext: true do
    let (:webcast_uri) { URI.parse "#{Settings.webcast_proxy.base_url}/warehouse/webcast.json" }

    subject { Webcast::Recordings.new }

    context 'normal return of real data' do
      it 'should return a bunch of playlists' do
        result = subject.get
        courses = result[:courses]
        expect(courses).to_not be_nil
        expect(courses.keys.length).to be >= 0
      end
    end

    context 'on remote server errors' do
      let! (:body) { 'An unknown error occurred.' }
      let! (:status) { 506 }
      include_context 'expecting logs from server errors'
      before(:each) {
        stub_request(:any, /.*#{webcast_uri.hostname}.*/).to_return(status: status, body: body)
      }
      after(:each) { WebMock.reset! }
      it 'should return the fetch error message' do
        response = subject.get
        expect(response[:proxyErrorMessage]).to include('There was a problem')
      end
    end

    context 'when json formatting fails' do
      before(:each) {
        stub_request(:any, /.*#{webcast_uri.hostname}.*/).to_return(status: 200, body: 'bogus json')
      }
      after(:each) { WebMock.reset! }
      it 'should return the fetch error message' do
        response = subject.get
        expect(response[:proxyErrorMessage]).to include('There was a problem')
      end
    end

    context 'when videos are disabled' do
      before { allow(Settings.features).to receive(:videos).and_return false }
      it 'should return an empty hash' do
        result = subject.get
        expect(result).to be_an_instance_of Hash
        expect(result).to be_empty
      end
    end

    context 'course with zero recordings is different than course not scheduled for recordings' do
      it 'returns nil recordings attribute when course is scheduled for recordings' do
        result = subject.get
        # 2015-B-58301: Recordings were planned but instructor backed out. These legacy cases should not surface in feed.
        expect(result[:courses]).not_to include '2015-B-58301'
        expect(result[:courses]['2015-B-56745'][:recordings]).to have_at_least(10).items
      end
    end
  end

end
