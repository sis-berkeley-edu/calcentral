describe CalnetCrosswalk::ByCsId do

  shared_examples 'a proxy that returns data' do
    it 'returns data with the expected structure' do
      expect(feed['Person']).to be
      expect(feed['Person']['identifiers'][0]['identifierValue']).to be
    end
  end

  shared_context 'looking up ids' do
    context 'CS ID lookup with consideration of \'isPrimaryForIdentifierType\' attribute' do
      subject { proxy.lookup_campus_solutions_id }
      it 'should return the primary CS ID' do
        expect(subject).to eq campus_solutions_id
      end
    end
  end

  context 'mock proxy' do
    let(:campus_solutions_id) { '5030615093' }
    let(:proxy) { CalnetCrosswalk::ByCsId.new(user_id: campus_solutions_id, fake: true) }
    let(:feed) { proxy.get[:feed] }
    it_behaves_like 'a proxy that returns data'
    it 'can be overridden to return errors' do
      proxy.set_response(status: 506, body: '')
      response = proxy.get
      expect(response[:errored]).to eq true
    end
    include_context 'looking up ids'
  end

end
