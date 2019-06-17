describe HubEdos::StudentApi::V2::Proxy do
  let(:uid) { random_id }
  let(:fake) { true }

  let(:worker) { HubEdosStudentApiV2Worker.new(required_options.merge(test_options)) }
  let(:required_options) { {user_id: random_id} }
  let(:test_options) { {} }
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
  let(:response_payload) { {'foo' => ['1','2','3']} }
  before do
    worker.set_response({
      status: 200,
      headers: {'Content-Type' => 'application/json'},
      body: api_response_body.to_json
    })
  end

  class HubEdosStudentApiV2Worker < HubEdos::StudentApi::V2::Proxy
    def json_filename
      'hub_generic.json'
    end
  end

  describe '#process_response_after_caching' do
    let(:test_options) { {} }
    context 'only \'foo\' field is specified to be included' do
      let(:test_options) { {include_fields: ['foo']} }
      let(:response) do
        {
          statusCode: 200,
          feed: {
            'student' => {
              'foo' => [1,2,3],
              'bar' => [4,5,6]
            }
          }
        }
      end
      it 'returns feed with only foo attribute' do
        result = worker.process_response_after_caching(response)
        expect(result[:feed]['student']['foo']).to eq [1,2,3]
        expect(result[:feed]['student']['bar']).to eq nil
      end
    end
    context 'response indicates that student not found (404)' do
      let(:response) { {studentNotFound: true} }
      it 'returns feed without error indication' do
        result = worker.process_response_after_caching(response)
        expect(result[:errored]).to eq nil
      end
    end
    context 'response indicate that no student id found' do
      let(:response) { {noStudentId: true} }
      it 'returns feed without error indication' do
        result = worker.process_response_after_caching(response)
        expect(result[:errored]).to eq nil
      end
    end
    context 'response indicates http error' do
      let(:response) do
        {
          statusCode: 500,
          feed: {
            'student' => {'foo' => 'fighters'}
          }
        }
      end
      it 'returns feed with error indication' do
        result = worker.process_response_after_caching(response)
        expect(result[:errored]).to eq true
      end
    end
  end

  describe '#filter_fields' do
    let(:input_hash) do
      {
        'foo' => 'foofighters rock',
        'bar' => 'a place to drink beer'
      }
    end
    context 'when whitelisted fields are not present' do
      let(:whitelisted_fields) { [] }
      it 'returns unfiltered hash' do
        result = worker.filter_fields(input_hash, whitelisted_fields)
        expect(result.keys).to eq ['foo','bar']
      end
    end
    context 'when whitelisted fields are present' do
      let(:whitelisted_fields) { ['foo'] }
      it 'returns filtered hash' do
        result = worker.filter_fields(input_hash, whitelisted_fields)
        expect(result.keys).to eq ['foo']
      end
    end
  end

end
