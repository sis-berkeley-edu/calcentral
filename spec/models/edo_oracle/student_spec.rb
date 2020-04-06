describe EdoOracle::Student do
  describe '#concurrent?' do
    subject { described_class.new({user_id: uid}).concurrent? }
    let(:concurrent_status_hash) { { 'concurrent_status' => concurrent_status} }
    before do
      allow(User::Identifiers).to receive(:lookup_campus_solutions_id).and_return student_id
      allow(EdoOracle::Queries).to receive(:get_concurrent_student_status).and_return concurrent_status_hash
    end

    context 'when student is not in a concurrent program' do
      let(:concurrent_status) { 'N' }
      let(:uid) { 790833 }
      let(:student_id) { '39470174' }
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when student is in a concurrent program' do
      let(:concurrent_status) { 'Y' }
      let(:uid) { 300216 }
      let(:student_id) { '95727964' }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when student doesn\'t exist, student ID is null' do
      let(:concurrent_status_hash) { nil }
      let(:uid) { 000000 }
      let(:student_id) {nil}
      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '#concurrent without stub' do
    subject { described_class.new({user_id: uid}).concurrent? }

    context 'when student is not in a concurrent program' do
      let(:uid) { 300216 }
      it 'returns false' do
        expect(subject).to be false
      end
    end
  end
end
