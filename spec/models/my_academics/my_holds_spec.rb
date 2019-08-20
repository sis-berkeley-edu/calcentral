describe MyAcademics::MyHolds do
  describe '#get_feed_internal' do
    subject { described_class.new(random_id).get_feed_internal }

    describe '#get_feed_internal' do
      let(:academic_status_proxy) { double(:academic_status_proxy, get: academic_status_response) }
      let(:academic_status_response) { nil }
      before { allow(HubEdos::StudentApi::V2::AcademicStatuses).to receive(:new).and_return(academic_status_proxy) }

      context 'when AcademicStatus response is nil' do
        let(:academic_status_response) { nil }
        it 'returns an empty response' do
          expect(subject[:feed]).to be
          expect(subject[:feed][:holds]).to eq []
        end
      end

      context 'when AcademicStatus response is empty' do
        let(:academic_status_response) { {} }
        it 'returns an empty response' do
          expect(subject[:feed]).to be
          expect(subject[:feed][:holds]).to eq []
        end
      end

      context 'when AcademicStatus returns an error response' do
        let(:academic_status_response) do
          {
            errored: true,
            statusCode: 503,
            body: 'An unknown server error occurred'
          }
        end
        it 'returns an empty response' do
          expect(subject).to be
          expect(subject[:feed]).to be
          expect(subject[:feed][:holds]).to eq []
        end
        it 'should pass along the errors' do
          expect(subject[:statusCode]).to eq 503
          expect(subject[:errored]).to eq true
        end
      end

      context 'when AcademicStatus response is populated' do
        let(:academic_status_proxy) { HubEdos::StudentApi::V2::AcademicStatuses.new(fake: true, user_id: '61889') }
        it 'should successfully return a response' do
          expect(subject[:errored]).to eq nil
          expect(subject[:statusCode]).to eq 200
          holds = subject[:feed][:holds]
          expect(holds.count).to eq 5
          expect(holds[0][:typeCode]).to eq 'R01'
          expect(holds[0][:reason]).to be
          expect(holds[0][:reason][:code]).to eq 'NOID'
          expect(holds[0][:reason][:description]).to eq 'No ID Provided at Cal 1 Card'
          expect(holds[0][:reason][:formalDescription]).to eq 'A government issue ID is required to receive a Cal 1 Card. A temporary Cal 1 Card was granted because you could not provide the required ID. You must provide a valid government issue ID to the Office of the Registrar before enrolling for the next term.'
          expect(holds[0][:fromDate]).to eq nil
          expect(holds[0][:fromTerm][:id]).to eq '2182'
          expect(holds[0][:fromTerm][:name]).to eq '2018 Spring'
          expect(holds[0][:contact][:description]).to eq ' '
          expect(holds[0][:amountRequired]).to eq 0
        end
      end
    end

  end
end
