describe User::Academics::Level do
  let(:bot_type) { {'code' => 'BOT', 'description' => 'Beginning of Term'} }
  let(:eot_type) { {'code' => 'EOT', 'description' => 'End of Term'} }
  let(:level_type) { bot_type }
  let(:level) { {'code' => '30', 'description' => 'Graduate'} }
  let(:data) { {'type' => level_type, 'level' => level} }
  subject { described_class.new(data) }

  describe '#type_code' do
    context 'when beginning of term type' do
      let(:level_type) { bot_type }
      it 'returns beginning of term type code' do
        expect(subject.type_code).to eq 'BOT'
      end
    end
    context 'when end of term type' do
      let(:level_type) { eot_type }
      it 'returns end of term type code' do
        expect(subject.type_code).to eq 'EOT'
      end
    end
  end

  describe '#description' do
    it 'returns level description' do
      expect(subject.description).to eq 'Graduate'
    end
  end
end
