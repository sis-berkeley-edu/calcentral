describe EdoOracle::Student do
  describe '#concurrent?' do
    subject { described_class.new({user_id: uid}).concurrent? }
    before do
      allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return student_id
    end

    context 'when student is not in a concurrent program' do
      let(:uid) { 790833 }
      let(:student_id) { '39470174' }
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when student is in a concurrent program' do
      let(:uid) { 300216 }
      let(:student_id) { '95727964' }

      it 'returns true' do
        expect(subject).to be true
      end
    end
  end
end
