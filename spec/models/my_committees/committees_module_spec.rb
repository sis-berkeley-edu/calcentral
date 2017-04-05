describe MyCommittees::CommitteesModule do

  let(:cs_committee) do
    {
      committeeType: cs_committee_type
    }
  end

  describe '#translate_committee_type' do
    subject { described_class.translate_committee_type(cs_committee) }

    context 'when committeeType is nil' do
      let(:cs_committee_type) { nil }
      it 'returns false' do
        expect(subject).to eq nil
      end
    end
    context 'when committeeType is not a string' do
      let(:cs_committee_type) { {} }
      it 'returns false' do
        expect(subject).to eq nil
      end
    end
    context 'when committeeType is garbage' do
      let(:cs_committee_type) { 'GARBAGE' }
      it 'returns false' do
        expect(subject).to eq nil
      end
    end
    context 'when committeeType is QE' do
      let(:cs_committee_type) { 'QE' }
      it 'returns true' do
        expect(subject).to eq 'Qualifying Exam Committee'
      end
    end
    context 'when committeeType is PLN1MASTER' do
      let(:cs_committee_type) { 'PLN1MASTER' }
      it 'returns false' do
        expect(subject).to eq 'Master\'s Thesis Committee'
      end
    end
    context 'when committeeType is DOCTORAL' do
      let(:cs_committee_type) { 'DOCTORAL' }
      it 'returns true' do
        expect(subject).to eq 'Dissertation Committee'
      end
    end
  end

  describe '#qualifying_exam?' do
    subject { described_class.qualifying_exam?(cs_committee) }

    context 'when committeeType is nil' do
      let(:cs_committee_type) { nil }
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when committeeType is not a string' do
      let(:cs_committee_type) { 123 }
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when committeeType is garbage' do
      let(:cs_committee_type) { 'GARBAGE' }
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when committeeType is a valid non-QE type' do
      let(:cs_committee_type) { 'PLN1MASTER' }
      it 'returns false' do
        expect(subject).to be false
      end
    end
    context 'when committeeType is QE' do
      let(:cs_committee_type) { 'QE' }
      it 'returns true' do
        expect(subject).to be true
      end
    end
  end
end
