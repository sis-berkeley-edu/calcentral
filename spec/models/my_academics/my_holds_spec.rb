describe MyAcademics::MyHolds do
  describe '#get_feed_internal' do
    subject { described_class.new(random_id).get_feed_internal }

    shared_examples 'a model receiving no data' do
      it 'returns an empty response' do
        expect(subject).to be
        expect(subject[:feed]).to be
        expect(subject[:feed][:holds]).to eq []
      end
    end

    context 'when AcademicStatus response is nil' do
      before do
        allow_any_instance_of(HubEdos::V1::AcademicStatus).to receive(:get).and_return(nil)
      end
      it_behaves_like 'a model receiving no data'
    end
    context 'when AcademicStatus response is empty' do
      before do
        allow_any_instance_of(HubEdos::V1::AcademicStatus).to receive(:get).and_return({})
      end
      it_behaves_like 'a model receiving no data'
    end
    context 'when AcademicStatus returns an error response' do
      before do
        allow_any_instance_of(HubEdos::V1::AcademicStatus).to receive(:get).and_return(failure_response)
      end
      let(:failure_response) { {:errored=>true, :statusCode=>503, :body=>"An unknown server error occurred"} }
      it_behaves_like 'a model receiving no data'
      it 'should pass along the errors' do
        expect(subject[:statusCode]).to eq 503
        expect(subject[:errored]).to eq true
      end
    end
    context 'when AcademicStatus response is populated' do
      before do
        fake_proxy = HubEdos::V1::AcademicStatus.new(fake: true, user_id: '61889')
        allow(HubEdos::V1::AcademicStatus).to receive(:new).and_return fake_proxy
      end
      it 'should successfully return a response' do
        holds = subject[:feed][:holds]
        expect(holds.count).to eq 3

        expect(holds[0][:reason]).to be
        expect(holds[0][:reason][:description]).to eq 'Undeclared Senior'
        expect(holds[0][:reason][:formalDescription]).to eq 'You have exceeded 90 units without a major, please see your College advisor.'
        expect(holds[0][:fromDate]).to eq '2016-03-23'
        expect(holds[0][:fromTerm]).to be
        expect(holds[0][:fromTerm][:name]).to eq '2018 Spring'
        expect(holds[0][:amountRequired]).to eq 0
        expect(holds[0][:contact]).to be
        expect(holds[0][:contact][:description]).to eq ''

        expect(holds[1][:reason]).to be
        expect(holds[1][:reason][:description]).to eq 'Graduating Seniors'
        expect(holds[1][:reason][:formalDescription]).to eq ''
        expect(holds[1][:fromDate]).not_to be
        expect(holds[1][:fromTerm]).to be
        expect(holds[1][:fromTerm][:name]).to eq '2020 Spring'
        expect(holds[1][:amountRequired]).to eq 0
        expect(holds[1][:contact]).to be
        expect(holds[1][:contact][:description]).to eq ''

        expect(holds[2][:reason]).to be
        expect(holds[2][:reason][:description]).to eq 'Unpaid charges on account'
        expect(holds[2][:reason][:formalDescription]).to eq 'Our records indicate you have past due charges on your billing account. These charges are for terms through Spring/Summer 2016. Make payment through Bear Facts > CARS > e-Bill. For assistance, contact Cal Student Central at 510-664-9181 or open a case at http://studentcentral.berkeley.edu/.'
        expect(holds[2][:fromDate]).to eq '2016-07-02'
        expect(holds[2][:fromTerm]).to be
        expect(holds[2][:fromTerm][:name]).not_to be
        expect(holds[2][:amountRequired]).to eq 0
        expect(holds[2][:contact]).to be
        expect(holds[2][:contact][:description]).to eq ''
      end
    end
  end
end
