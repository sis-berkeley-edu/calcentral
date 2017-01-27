describe HubEnrollments::TermEnrollments do

  context 'mock proxy' do
    let(:proxy) { HubEnrollments::TermEnrollments.new(fake: true, user_id: '61889', term_id: 2172) }
    subject { proxy.get }

    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed][0]["enrollmentStatus"]).to be
      expect(subject[:feed][0]["enrollmentStatus"]["status"]).to be
      expect(subject[:feed][0]["grades"][0]["type"]["code"]).to eq 'MID'
      expect(subject[:feed][0]["gradingBasis"]["code"]).to eq 'GRD'
      expect(subject[:feed][0]["classSection"]["id"]).to eq 10633
    end
  end
end
