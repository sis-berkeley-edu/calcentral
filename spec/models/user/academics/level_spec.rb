describe User::Academics::Level do
  let(:bot_type) { {'code' => 'BOT', 'description' => 'Beginning of Term'} }
  let(:eot_type) { {'code' => 'EOT', 'description' => 'End of Term'} }
  let(:level_type) { bot_type }
  let(:level) { {'code' => '30', 'description' => 'Graduate'} }
  let(:data) { {'type' => level_type, 'level' => level} }
  subject { described_class.new(data) }

  describe '#type_code' do
    it 'returns type code' do
      expect(subject.type_code).to eq 'BOT'
    end
  end

  describe '#preferred_for_career_code?' do
    let(:career_code) { 'GRAD' }
    let(:result) { subject.preferred_for_career_code?(career_code) }
    context 'when level is end of term type' do
      let(:level_type) { eot_type }
      context 'when career code is not LAW' do
        let(:career_code) { 'GRAD' }
        it 'returns false' do
          expect(result).to eq false
        end
      end
      context 'when career code is LAW' do
        let(:career_code) { 'LAW' }
        it 'returns true' do
          expect(result).to eq true
        end
      end
    end
    context 'when level is beginning of term type' do
      let(:level_type) { bot_type }
      context 'when career code is not LAW' do
        let(:career_code) { 'GRAD' }
        it 'returns true' do
          expect(result).to eq true
        end
      end
      context 'when career code is LAW' do
        let(:career_code) { 'LAW' }
        it 'returns false' do
          expect(result).to eq false
        end
      end
    end
  end

  describe '#end_of_term?' do
    context 'when level is end of term type' do
      let(:level_type) { eot_type }
      it 'returns true' do
        expect(subject.end_of_term?).to eq true
      end
    end
    context 'when level is not end of term type' do
      let(:level_type) { bot_type }
      it 'returns false' do
        expect(subject.end_of_term?).to eq false
      end
    end
  end

  describe '#beginning_of_term?' do
    context 'when level is beginning of term type' do
      let(:level_type) { bot_type }
      it 'returns true' do
        expect(subject.beginning_of_term?).to eq true
      end
    end
    context 'when level is not beginning of term type' do
      let(:level_type) { eot_type }
      it 'returns false' do
        expect(subject.beginning_of_term?).to eq false
      end
    end
  end

  describe '#description' do
    it 'returns level description' do
      expect(subject.description).to eq 'Graduate'
    end
  end
end
