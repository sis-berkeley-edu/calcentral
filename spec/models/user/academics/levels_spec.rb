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

  describe '#preferred_for_career_code' do
    let(:career_code) { 'GRAD' }
    let(:result) { subject.preferred_for_career_code(career_code) }
    context 'when career code is LAW' do
      let(:career_code) { 'LAW' }
      it 'returns end of term level' do
        expect(result.end_of_term?).to eq true
      end
    end
    context 'when career code is not LAW' do
      let(:career_code) { 'GRAD' }
      it 'returns beginning of term level' do
        expect(result.beginning_of_term?).to eq true
      end
    end
  end

end
