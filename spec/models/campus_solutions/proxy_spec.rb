describe CampusSolutions::Proxy do

  context 'error' do
    subject { CampusSolutions::Proxy.new(uid: random_id) }
    before {
      response = double
      allow(Proxies::HttpRequest).to receive(:new).and_return double perform: response
      allow(response).to receive(:code).and_return double
      allow(response).to receive(:body).and_return double force_encoding: nil
      allow(response).to receive(:parsed_response).and_return feed
    }
    shared_examples 'a proxy that handles errors' do
      it 'should flag error condition' do
        processed_feed = HashConverter.downcase_and_camelize feed
        expect(subject.is_errored? processed_feed).to be true
        expect(subject.get).to eq ({ statusCode: 400, errored: true, feed: processed_feed })
      end
    end

    context 'errmsgtext in response' do
      let(:feed) { { 'ERRMSGTEXT' => 'Wicked problems' } }
      it_behaves_like 'a proxy that handles errors'
    end

    context 'invalid response' do
      let(:feed) { '<HTML><HEAD><TITLE>RESTListeningConnector</TITLE></HEAD><BODY>Unable to find a Routing corresponding to the incoming request message.</BODY></HTML>' }
      it_behaves_like 'a proxy that handles errors'
    end
  end
end
