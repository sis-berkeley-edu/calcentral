describe EdoOracle::Career, testext: false do

  describe '#fetch' do
    subject { described_class.new({user_id: uid}).fetch }
    let(:uid) { 790833 }
    it 'returns the expected result' do
      expect(subject).to be
      expect(subject.count).to be 2

      expect(subject[0].count).to eq 10
      expect(subject[0]).to have_keys(%w(acad_career program_status total_cumulative_units total_cumulative_law_units))
      expect(subject[0]).to have_keys(%w(total_transfer_units transfer_units_adjustment ap_test_units ib_test_units alevel_test_units total_transfer_units_law))

      expect(subject[1].count).to eq 10
      expect(subject[1]).to have_keys(%w(acad_career program_status total_cumulative_units total_cumulative_law_units))
      expect(subject[1]).to have_keys(%w(total_transfer_units transfer_units_adjustment ap_test_units ib_test_units alevel_test_units total_transfer_units_law))
    end
  end
end
