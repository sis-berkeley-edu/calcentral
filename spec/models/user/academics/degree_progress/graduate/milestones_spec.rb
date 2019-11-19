describe User::Academics::DegreeProgress::Graduate::Milestones do
  let(:user) { User::Current.new('61889') }
  let(:academic_career_code) { 'GRAD' }
  let(:academic_program_code) { 'GACAD' }
  let(:academic_plan_code) { '79249PHDG' }
  let(:requirements) do
    [
      {
        name: 'Advancement to Candidacy PhD',
        code: 'AAGADVPHD',
        dateCompleted: '2016-12-16',
        dateAnticipated: nil,
        status: 'Y',
        effdt: '2017-03-26',
        attempts: [
          {
            attemptDate: '2016-12-16',
            attemptNbr: '1',
            attemptStatus: nil,
            effdt: '2017-03-26'
          }
        ]
      }
    ]
  end
  let(:milestones_array) do
    [
      {
        acadCareer: academic_career_code,
        acadDegreeStatus: 'AW',
        acadPlan: 'Education PhD',
        acadPlanCode: academic_plan_code,
        acadProg: 'Graduate Academic Programs',
        acadProgCode: academic_program_code,
        requirements: requirements,
      }
    ]
  end
  let(:milestones_cached) { double(get_feed: milestones_array) }
  before { allow(User::Academics::DegreeProgress::Graduate::MilestonesCached).to receive(:new).with(user).and_return(milestones_cached) }
  subject { described_class.new(user) }

  describe '#user' do
    it 'returns user' do
      expect(subject.user).to be_an_instance_of User::Current
      expect(subject.user.uid).to eq '61889'
    end
  end

  describe '#all' do
    context 'when milestones all include requirements' do
      let(:requirements) do
        [{name: 'Advancement to Candidacy PhD', code: 'AAGADVPHD'}]
      end
      it 'returns all milestones' do
        expect(subject.all.count).to eq 1
      end
    end
    context 'when milestone included without requirements' do
      let(:requirements) { [] }
      it 'excludes milestone without requirements' do
        expect(subject.all.count).to eq 0
      end
    end
  end

  describe '#as_json' do
    it 'returns hash representation' do
      result = subject.as_json.first
      expect(result[:acadCareer]).to eq 'GRAD'
      expect(result[:acadProgCode]).to eq 'GACAD'
      expect(result[:acadDegreeStatus]).to eq 'AW'
      expect(result[:acadPlan]).to eq 'Education PhD'
      expect(result[:acadPlanCode]).to eq '79249PHDG'
      expect(result[:acadProg]).to eq 'Graduate Academic Programs'
      expect(result[:requirements].count).to eq 1
      expect(result[:requirements][0][:name]).to eq 'Advancement to Candidacy'
    end
  end

  describe '#all_except_law_nonacademic' do
    context 'when law academic milestones are present' do
      let(:academic_career_code) { 'LAW' }
      let(:academic_program_code) { 'LACAD' }
      it 'includes them in result' do
        expect(subject.all_except_law_nonacademic.count).to eq 1
      end
    end
    context 'when law non-academic milestones are present' do
      let(:academic_career_code) { 'LAW' }
      let(:academic_program_code) { 'LPRFL' }
      it 'excludes them from result' do
        expect(subject.all_except_law_nonacademic.count).to eq 0
      end
    end
    context 'when non-law milestones are present' do
      let(:academic_career_code) { 'GRAD' }
      let(:academic_program_code) { 'GACAD' }
      it 'includes them in result' do
        expect(subject.all_except_law_nonacademic.count).to eq 1
      end
    end
  end

end
