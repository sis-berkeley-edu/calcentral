describe User::Academics::Levels do
  let(:data) do
    [
      {
        'type' => {'code' => 'BOT', 'description' => 'Beginning of Term'},
        'level' => {'code' => 'P3', 'description' => 'Professional Year 2'}
      },
      {
        'type' => {'code' => 'EOT', 'description' => 'End of Term'},
        'level' => {'code' => 'P3', 'description' => 'Professional Year 3'}
      }
    ]
  end
  subject { described_class.new(data) }

  describe '#all' do
    it 'returns all levels' do
      result = subject.all
      expect(result.count).to eq 2
      expect(result.collect(&:type_code)).to eq ['BOT', 'EOT']
    end
  end
end
