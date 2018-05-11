describe EdoOracle::Career, testext: false do

  describe '#fetch' do
    subject { described_class.new({user_id: uid}).fetch }
    let(:uid) { 790833 }
    it 'returns the expected result' do
      expect(subject).to be
      expect(subject.count).to be 2

      expect(subject[0].count).to eq 4
      expect(subject[0]).to have_key('acad_career')
      expect(subject[0]).to have_key('program_status')
      expect(subject[0]).to have_key('total_cumulative_units')
      expect(subject[0]).to have_key('total_cumulative_law_units')

      expect(subject[1].count).to eq 4
      expect(subject[1]).to have_key('acad_career')
      expect(subject[1]).to have_key('program_status')
      expect(subject[1]).to have_key('total_cumulative_units')
      expect(subject[1]).to have_key('total_cumulative_law_units')
    end
  end
end
