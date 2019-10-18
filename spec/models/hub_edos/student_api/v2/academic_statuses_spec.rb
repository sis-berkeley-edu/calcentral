describe HubEdos::StudentApi::V2::AcademicStatuses do
  let(:uid) { random_id }
  subject { described_class.new(fake: true, user_id: random_id) }

  context '#new' do
    context 'when include_inactive_programs option included' do
      subject { described_class.new(fake: true, user_id: random_id, include_inactive_programs: true) }
      it 'sets include_inactive_programs boolean' do
        expect(subject.include_inactive_programs).to eq true
        expect(subject.include_completed_programs).to eq false
      end
    end
    context 'when include_completed_programs option included' do
      subject { described_class.new(fake: true, user_id: random_id, include_completed_programs: true) }
      it 'sets include_completed_programs boolean' do
        expect(subject.include_completed_programs).to eq true
        expect(subject.include_inactive_programs).to eq false
      end
    end
  end

  context '#url' do
    context 'when include incomplete programs options is true' do
      subject { described_class.new(fake: true, user_id: random_id, include_inactive_programs: true) }
      it 'specifies true in get request' do
        expect(subject.url).to eq 'https://sis-integration.berkeley.edu/apis/sis/v2/students/25738808?inc-acad=true&inc-inactive-programs=true&inc-completed-programs=false'
      end
    end

    context 'when include completed programs options is true' do
      subject { described_class.new(fake: true, user_id: random_id, include_completed_programs: true) }
      it 'specifies true in get request' do
        expect(subject.url).to eq 'https://sis-integration.berkeley.edu/apis/sis/v2/students/25738808?inc-acad=true&inc-inactive-programs=false&inc-completed-programs=true'
      end
    end
  end

  context '#get' do
    let(:result) { subject.get }
    it 'filters out base attributes' do
      expect(result[:statusCode]).to eq 200
      expect(result[:feed].has_key?('names')).to eq false
      expect(result[:feed].has_key?('identifiers')).to eq false
      expect(result[:feed].has_key?('affiliations')).to eq false
      expect(result[:feed].has_key?('confidential')).to eq false
    end

    it 'returns holds' do
      expect(result[:feed]['holds']).to be
      expect(result[:feed]['holds'].count).to eq 5
      result[:feed]['holds'].each do |hold|
        expect(hold['type']['code']).to be
        expect(hold['type']['description']).to be
        expect(hold['reason']['code']).to be
        expect(hold['reason']['description']).to be
        expect(hold['reference']).to be
        expect(hold['amountRequired']).to be
        expect(hold['department']['code']).to be
        expect(hold['department']['description']).to be
        expect(hold['contact']['code']).to be
        expect(hold['contact']['description']).to be
      end
    end

    it 'returns academic statuses' do
      expect(result[:feed]['academicStatuses']).to be
      expect(result[:feed]['academicStatuses'].count).to eq 1
      result[:feed]['academicStatuses'].each do |academicStatus|
        expect(academicStatus['cumulativeGPA']).to be
        expect(academicStatus['cumulativeUnits']).to be
        expect(academicStatus['studentCareer']).to be
        expect(academicStatus['studentPlans']).to be
      end
    end

    it 'returns degrees' do
      expect(result[:feed]['degrees']).to be_an_instance_of(Array)
      expect(result[:feed]['degrees'].count).to eq 0
    end

    it 'returns award honors' do
      expect(result[:feed]['awardHonors']).to be_an_instance_of(Array)
      expect(result[:feed]['awardHonors'].count).to eq 0
    end
  end
end
