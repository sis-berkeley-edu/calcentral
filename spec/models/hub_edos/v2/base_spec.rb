describe HubEdos::V2::Base do
  let(:uid) { random_id }
  let(:student_id) { random_id }
  let(:student_api_v2_response_payload) do
    {
      'identifiers' => [
        {
          'disclose' => true,
          'id' => student_id,
          'type' => 'student-id'
        },
        {
          'disclose' => true,
          'id' => uid,
          'type' => 'campus-uid'
        },
    ],
    }
  end
  let(:student_api_v2_response_body_200) do
    {
      'apiResponse' => {
        'httpStatus' => {
          'code' => '200',
          'description' => 'OK'
        },
        'response' => student_api_v2_response_payload,
        'responseType' => "namespaceURI=\"http://bmeta.berkeley.edu/student/studentV1.xsd\" element=\"student\""
      }
    }
  end
  let(:student_api_v2_response_body_404) do
    {
      'apiResponse' => {
        'httpStatus' => {
          'code' => '404',
          'description' => 'Not Found',
          'formalDescription' => "Could not find data for id=#{student_id}"
        }
      }
    }
  end

  class Worker < HubEdos::V2::Base
    def json_filename
      'hub_v2_academic_status.json'
    end
  end

  let(:worker) { Worker.new(user_id: uid) }
  subject { worker.get }

  context 'when student data returned by API' do
    before { allow_any_instance_of(Worker).to receive(:mock_json).and_return(student_api_v2_response_body_200.to_json) }

    it 'returns unwrapped feed' do
      expect(subject[:statusCode]).to eq 200
      expect(subject[:feed]['identifiers'].count).to eq 2
    end
  end

  context 'when student data not found by API' do
    before do
      worker.set_response({
        status: 404,
        headers: {'Content-Type' => 'application/json'},
        body: student_api_v2_response_body_404.to_json
      })
    end
    it 'returns http response with error' do
      expect(subject[:statusCode]).to eq 404
      expect(subject[:feed].empty?).to eq true
      expect(subject[:feed].keys).to eq []
    end
  end

  context 'when campus solutions id cannot be found' do
    before { allow_any_instance_of(Worker).to receive(:lookup_campus_solutions_id).and_return(nil) }
    it 'returns http response indicating no student' do
      expect(subject.has_key?(:statusCode)).to eq false
      expect(subject[:feed].empty?).to eq true
      expect(subject[:feed].keys).to eq []
      expect(subject[:noStudentId]).to eq true
    end
  end

end
