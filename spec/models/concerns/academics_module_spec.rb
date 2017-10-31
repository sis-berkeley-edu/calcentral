describe Concerns::AcademicsModule do

  describe '#semester_info' do
    subject { described_class.semester_info term_key }

    let(:current_term) { double(:year => 2018, :code => 'B') }
    before do
      allow(described_class).to receive(:current_term).and_return current_term
    end

    context 'when term_key is missing' do
      let(:term_key) { nil }
      it 'returns an empty object' do
        expect(subject).to eq({})
      end
    end
    context 'when term_key is invalid' do
      let(:term_key) { 'ABC' }
      it 'returns an empty object' do
        expect(subject).to eq({})
      end
    end
    context 'when term_key is valid' do
      let(:term_key) { '2017-D' }
      it 'returns an object populated with term data' do
        expect(subject).to be
        expect(subject[:name]).to eq 'Fall 2017'
        expect(subject[:slug]).to eq 'fall-2017'
        expect(subject[:termId]).to eq '2178'
        expect(subject[:termCode]).to eq 'D'
        expect(subject[:termYear]).to eq '2017'
        expect(subject[:timeBucket]).to eq 'past'
        expect(subject[:campusSolutionsTerm]).to be true
        expect(subject[:gradingInProgress]).to be nil
        expect(subject[:classes]).to eq []
      end
    end
  end
end
