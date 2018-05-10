describe Concerns::Careers do

  let(:active_career) do
    {
      'program_status' => 'AC'
    }
  end
  let(:inactive_career) do
    {
      'program_status' => nil
    }
  end

  describe '#active?' do
    subject { described_class.active? career }

    context 'when career is active' do
      let(:career) { active_career }
      it 'returns true' do
        expect(subject).to eq true
      end
    end
    context 'when career is inactive' do
      let(:career) { inactive_career }
      it 'returns false' do
        expect(subject).to eq false
      end
    end
    context 'when career is missing' do
      let(:career) { nil }
      it 'returns false' do
        expect(subject).to eq false
      end
    end
    context 'when career is malformed' do
      let(:career) do
        {
          foo: 'bar'
        }
      end
      it 'returns false' do
        expect(subject).to eq false
      end
    end
  end

  describe '#active_or_all' do
    subject { described_class.active_or_all careers }

    context 'when no careers are active' do
      let(:careers) { [inactive_career, inactive_career] }
      it 'returns all careers' do
        expect(subject).to contain_exactly(inactive_career, inactive_career)
      end
    end
    context 'when all careers are active' do
      let(:careers) { [active_career, active_career] }
      it 'returns all careers' do
        expect(subject).to contain_exactly(active_career, active_career)
      end
    end
    context 'when some careers are active' do
      let(:careers) { [inactive_career, active_career] }
      it 'returns only active careers' do
        expect(subject).to contain_exactly(active_career)
      end
    end
    context 'when careers is nil' do
      let(:careers) { nil }
      it 'returns nil' do
        expect(subject).to be nil
      end
    end
    context 'when careers is empty' do
      let(:careers) { [] }
      it 'returns empty' do
        expect(subject).to eq []
      end
    end
  end
end
