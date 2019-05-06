describe EdoOracle::Career do

  describe '#fetch' do
    subject { described_class.new({user_id: uid}).fetch }

    context 'user id 790833' do
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

    context 'user id 300216' do
      let(:uid) { 300216 }
      it 'returns the expected result' do
        expect(subject).to be
        expect(subject.count).to be 3

        expect(subject[0].count).to eq 10
        expect(subject[0]).to have_keys(%w(acad_career program_status total_cumulative_units total_cumulative_law_units))
        expect(subject[0]).to have_keys(%w(total_transfer_units transfer_units_adjustment ap_test_units ib_test_units alevel_test_units total_transfer_units_law))

        expect(subject[1].count).to eq 10
        expect(subject[1]).to have_keys(%w(acad_career program_status total_cumulative_units total_cumulative_law_units))
        expect(subject[1]).to have_keys(%w(total_transfer_units transfer_units_adjustment ap_test_units ib_test_units alevel_test_units total_transfer_units_law))

        expect(subject[2].count).to eq 10
        expect(subject[2]).to have_keys(%w(acad_career program_status total_cumulative_units total_cumulative_law_units))
        expect(subject[2]).to have_keys(%w(total_transfer_units transfer_units_adjustment ap_test_units ib_test_units alevel_test_units total_transfer_units_law))
      end
    end
  end

  describe '#get_cumulative_units' do
    subject { described_class.new({user_id: uid}).get_cumulative_units }
    context 'user id 790833' do
      let(:uid) { 790833 }
      it 'returns the expected result' do
        expect(subject).to be
        expect(subject.count).to be 1
        expect(subject[0]).to have_keys(%w(acad_career program_status total_cumulative_units total_cumulative_law_units))
        expect(subject[0]['total_cumulative_units']).to eq 2.0
        expect(subject[0]['total_cumulative_law_units']).to be_nil
      end
    end

    context 'user id 300216' do
      let(:uid) {300216}
      it 'returns the expected result' do
      expect(subject).to be
      expect(subject.count).to be 3
      for i in 0..2
        expect(subject[i]).to have_keys(%w(acad_career program_status total_cumulative_units total_cumulative_law_units))
      end
      expect(subject[0]['total_cumulative_units']).to eq 16.0
      expect(subject[0]['total_cumulative_law_units']).to eq 0.0
      expect(subject[1]['total_cumulative_units']).to eq 61.0
      expect(subject[1]['total_cumulative_law_units']).to eq 46.0
      expect(subject[2]['total_cumulative_units']).to eq 157.0
      expect(subject[2]['total_cumulative_law_units']).to eq 0.0
      end
    end
  end
end
