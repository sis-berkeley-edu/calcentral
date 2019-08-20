describe HubEdos::Proxy do
  let(:uid) { random_id }
  let(:student_id) { random_id }
  let(:response_payload) { {'foo' => ['1','2','3']} }
  let(:api_response_body) do
    {
      'apiResponse' => {
        'httpStatus' => {
          'code' => '200',
          'description' => 'OK'
        },
        'response' => response_payload,
        'responseType' => "namespaceURI=\"http://bmeta.berkeley.edu/foobar/foobarV0.xsd\" element=\"student\""
      }
    }
  end

  class HubEdosProxyWorker < HubEdos::Proxy
    def json_filename
      'hub_generic.json'
    end
  end

  describe '#get' do
    let(:worker) { HubEdosProxyWorker.new(user_id: uid) }
    subject { worker.get }

    context 'when HTTP 200 response returned by API' do
      before do
        worker.set_response({
          status: 200,
          headers: {'Content-Type' => 'application/json'},
          body: api_response_body.to_json
        })
      end

      it 'returns unwrapped feed' do
        expect(subject[:statusCode]).to eq 200
        expect(subject[:feed]['foo'].count).to eq 3
        expect(subject[:feed]['foo'][0]).to eq '1'
        expect(subject[:feed]['studentNotFound']).to eq nil
      end
    end

    context 'when HTTP 400 response returns by API' do
      before do
        worker.set_response({
          status: 404,
          headers: {'Content-Type' => 'application/json'},
          body: api_response_body.to_json
        })
      end
      it 'returns http response with error' do
        expect(subject[:statusCode]).to eq 404
        expect(subject[:feed].empty?).to eq true
        expect(subject[:feed].keys).to eq []
        expect(subject[:studentNotFound]).to eq true
      end
    end

    context 'when campus solutions id cannot be found' do
      before { allow_any_instance_of(HubEdosProxyWorker).to receive(:lookup_campus_solutions_id).and_return(nil) }
      it 'returns http response indicating no student' do
        puts "subject: #{subject.inspect}"
        expect(subject.has_key?(:statusCode)).to eq false
        expect(subject[:feed].empty?).to eq true
        expect(subject[:feed].keys).to eq []
        expect(subject[:noStudentId]).to eq true
      end
    end

    context 'when exception is raised in processing the response' do
      before { allow_any_instance_of(HubEdosProxyWorker).to receive(:get_internal).and_raise(ArgumentError, 'foo') }
      it 'returns http response with error wrapper' do
        expect(subject[:statusCode]).to eq 503
        expect(subject[:errored]).to eq true
        expect(subject[:body]).to eq "An unknown server error occurred"
      end
    end

    context 'when API responds with server error' do
      before do
        worker.set_response({
          status: 500,
          headers: {'Content-Type' => 'application/json'},
          body: nil
        })
      end
      it 'returns http response with generic error' do
        expect(subject[:statusCode]).to eq 503
        expect(subject[:body]).to eq 'An unknown server error occurred'
        expect(subject[:errored]).to eq true
      end
    end
  end
end
