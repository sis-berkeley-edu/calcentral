describe User::Academics::DegreeProgress::Graduate::Attempt do
  let(:data) do
    {
      attemptNbr: '1',
      attemptDate: '2016-12-16',
      attemptStatus: 'P',
      effdt: '2017-03-26'
    }
  end
  subject { described_class.new(data) }

  describe '#sequence_number' do
    it 'returns sequence number' do
      expect(subject.sequence_number).to eq 1
    end
  end

  describe '#date' do
    it 'returns date' do
      expect(subject.date).to be_an_instance_of DateTime
      expect(subject.date.to_s).to eq '2016-12-16T00:00:00-08:00'
    end
  end

  describe '#date_formatted' do
    it 'returns formatted date' do
      expect(subject.date_formatted).to eq 'Dec 16, 2016'
    end
  end

  describe '#status_code' do
    it 'returns status code' do
      expect(subject.status_code).to eq 'P'
    end
  end

  describe '#display_description' do
    it 'returns display description' do
      expect(subject.display_description).to eq 'Exam 1: Passed Dec 16, 2016'
    end
  end

  describe '#qualifying_exam_result' do
    it 'returns qualifying exam result status' do
      expect(subject.qualifying_exam_result).to eq 'Passed'
    end
  end

  describe '#as_json' do
    it 'returns hash representing requirement' do
      result = subject.as_json
      expect(result).to be_an_instance_of Hash
      expect(result[:sequenceNumber]).to eq 1
      expect(result[:statusCode]).to eq 'P'
      expect(result[:display]).to eq 'Exam 1: Passed Dec 16, 2016'
    end
  end

end
