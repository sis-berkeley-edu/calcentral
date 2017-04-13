describe CalnetCrosswalk::ByUid do

  shared_examples 'a proxy that returns data' do
    it 'returns data with the expected structure' do
      expect(feed['Person']).to be
      expect(feed['Person']['identifiers'][0]['identifierValue']).to be
    end
  end

  shared_context 'looking up ids' do
    context 'looking up cs id' do
      subject { proxy.lookup_campus_solutions_id }
      it 'should return the CS ID' do
        expect(subject).to be
      end
    end
  end

  context 'mock proxy' do
    let(:proxy) { CalnetCrosswalk::ByUid.new(user_id: '61889', fake: true) }
    let(:feed) { proxy.get[:feed] }
    it_behaves_like 'a proxy that returns data'
    it 'can be overridden to return errors' do
      proxy.set_response(status: 506, body: '')
      response = proxy.get
      expect(response[:errored]).to eq true
    end
    context 'Crosswalk \'isPrimaryForIdentifierType\' attribute' do
      subject { proxy.lookup_campus_solutions_id.to_i }
      it 'should return the primary CS ID' do
        expect(subject).to eq 11667051
      end
    end
    include_context 'looking up ids'
  end

  context 'real proxy', testext: true do
    let(:proxy) { CalnetCrosswalk::ByUid.new(user_id: '300940', fake: false) }
    let(:feed) { proxy.get[:feed] }
    it_behaves_like 'a proxy that returns data'
    include_context 'looking up ids'
  end

end
