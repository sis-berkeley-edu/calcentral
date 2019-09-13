describe User::Academics::Queries do
  let(:student_id) { '3031234560' }

  describe '.student_groups' do
    let(:result) { described_class.student_groups(student_id) }
    it 'returns student group rows' do
      student_groups = result.inject({}) { |map, row| map[row['student_group_code']] = row; map}
      expect(student_groups['R1TA']['student_group_description']).to eq '1 Term in Attendance'
      expect(student_groups['AWDP']['student_group_description']).to eq 'SIR Deposit Waiver'
      expect(student_groups['VELW']['student_group_description']).to eq 'Entry Level Writing'
      expect(student_groups['VAC']['student_group_description']).to eq 'American Cultures'
      expect(student_groups['AHC']['student_group_description']).to eq 'American History - Completed'
    end
  end
end
