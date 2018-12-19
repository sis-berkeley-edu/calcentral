describe MyAcademics::Grading::Period do
  before { allow(Settings.terms).to receive(:fake_now).and_return Time.parse('2017-03-02') }
  let(:start_date) { Time.parse('2017-03-06 00:00:00 UTC') }
  let(:end_date) { Time.parse('2017-03-10 00:00:00 UTC') }
  subject { described_class.new(start_date, end_date) }
  describe '#initialize' do
    it 'initializes with start and end date' do
      expect(subject.start_date).to eq start_date
      expect(subject.due_date).to eq end_date
    end
  end

  describe '#==' do
    let(:other_period) { MyAcademics::Grading::Period.new(start_date, other_end_date) }
    context 'when start date and due dates of self and other match' do
      let(:other_end_date) { Time.parse('2017-03-10 00:00:00 UTC') }
      it 'returns true' do
        expect(subject == other_period).to eq true
      end
    end
    context 'when start date and due dates of self and other do not match' do
      let(:other_end_date) { Time.parse('2017-03-11 00:00:00 UTC') }
      it 'returns false' do
        expect(subject == other_period).to eq false
      end
    end
  end

  describe '#formatted_date' do
    context 'when date not present' do
      let(:date) { nil }
      it 'returns nil' do
        expect(subject.formatted_date(date)).to eq nil
      end
    end
    context 'when date in current year' do
      let(:date) { Time.parse('2017-03-12 00:00:00 UTC') }
      it 'returns month and day string' do
        expect(subject.formatted_date(date)).to eq 'Mar 12'
      end
    end
    context 'when date in other year' do
      let(:date) { Time.parse('2015-03-12 00:00:00 UTC') }
      it 'returns month, day, and year string' do
        expect(subject.formatted_date(date)).to eq 'Mar 12, 2015'
      end
    end
  end
end
