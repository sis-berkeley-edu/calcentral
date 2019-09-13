describe User::Academics::StudentGroup do
  let(:data) do
    {
      'student_group_code' => 'VAC',
      'student_group_description' => 'American Cultures',
      'from_date' => DateTime.parse('Mon, 01 Jan 2018')
    }
  end
  subject { described_class.new(data) }

  describe '#code' do
    let(:result) { subject.code }
    it 'returns student group code' do
      expect(result).to eq 'VAC'
    end
  end

  describe '#as_json' do
    let(:result) { subject.as_json }
    it 'returns student group hash' do
      expect(result[:code]).to eq 'VAC'
      expect(result[:description]).to eq 'American Cultures'
      expect(result[:fromDate]).to eq DateTime.parse('Mon, 01 Jan 2018')
    end
  end
end
