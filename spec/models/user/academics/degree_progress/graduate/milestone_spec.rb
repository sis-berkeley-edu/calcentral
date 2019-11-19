describe User::Academics::DegreeProgress::Graduate::Milestone do
  let(:uid) { '61889' }
  let(:user) { User::Current.new(uid) }
  let(:data) do
    {
      acadCareer: 'GRAD',
      acadDegreeStatus: 'AW',
      acadProg: 'Graduate Academic Programs',
      acadProgCode: 'GACAD',
      acadPlan: 'Education PhD',
      acadPlanCode: '79249PHDG',
      requirements: requirements,
    }
  end
  let(:advancement_to_candidacy_phd_requirement) do
    {
      name: 'Advancement to Candidacy PhD',
      code: 'AAGADVPHD',
      dateCompleted: '2016-12-16',
      dateAnticipated: nil,
      status: 'Y',
      effdt: '2017-03-26',
      attempts: [
        {
          attemptNbr: '1',
          attemptDate: '2016-12-16',
          attemptStatus: nil,
          effdt: '2017-03-26'
        }
      ]
    }
  end
  let(:qualifying_exam_results_requirement) do
    {
      name: 'Qualifying Exam Results',
      code: 'AAGQERESLT',
      dateCompleted: '2016-12-15',
      dateAnticipated: nil,
      status: 'Y',
      effdt: '2017-03-26',
      attempts: [
        {
          attemptNbr: '1',
          attemptDate: '2016-12-15',
          attemptStatus: 'P',
          effdt: '2017-03-26'
        }
      ]
    }
  end

  let(:qualifying_exam_approval_requirement) do
    {
      name: 'Qualifying Exam Approval',
      code: 'AAGQEAPRV',
      dateCompleted: '2017-05-22',
      dateAnticipated: '2017-05-22',
      status: 'Y',
      effdt: '2017-03-26',
      attempts: [
        {
          attemptNbr: '1',
          attemptDate: '2016-12-15',
          attemptStatus: 'P',
          effdt: '2017-03-26'
        }
      ]
    }
  end
  let(:requirements) do
    [
      advancement_to_candidacy_phd_requirement,
      qualifying_exam_results_requirement,
      qualifying_exam_approval_requirement,
    ]
  end

  subject { described_class.new(data, user) }

  describe '.safe_iso8601_date_parse' do
    let(:date_string) { '' }
    let(:result) { described_class.safe_iso8601_date_parse(date_string) }
    context 'when date string not provided' do
      let(:date_string) { '' }
      it 'returns nil' do
        expect(result).to eq nil
      end
    end
    context 'when date string not in ISO 8601 date format' do
      let(:logger) { double(:logger) }
      let(:date_string) { '2019-XX-XX' }
      it 'returns nil' do
        expect(result).to eq nil
      end
      it 'logs error' do
        expected_log_msg = "Bad date format: #{date_string}"
        expect(logger).to receive(:error).with(expected_log_msg)
        expect(Rails).to receive(:logger).and_return(logger)
        expect(result).to eq nil
      end
    end
    context 'when date string is in ISO 8601 date format' do
      let(:date_string) { '2019-01-01' }
      it 'returns date time object' do
        expect(result).to be_an_instance_of DateTime
        expect(result.to_s).to eq '2019-01-01T00:00:00-08:00'
      end
    end
  end

  describe '#has_requirements?' do
    context 'when no requirements present' do
      let(:requirements) { [] }
      it 'returns false' do
        expect(subject.has_requirements?).to eq false
      end
    end
    context 'when requirements present' do
      let(:requirements) { [advancement_to_candidacy_phd_requirement] }
      it 'returns true' do
        expect(subject.has_requirements?).to eq true
      end
    end
  end

  describe '#format_date' do
    let(:date_time) { DateTime.parse('2019-01-01T00:00:00-08:00') }
    it 'returns date in display format' do
      expect(described_class.format_date(date_time)).to eq 'Jan 01, 2019'
    end
  end

  describe '#user' do
    it 'returns user associated with milestone' do
      expect(subject.user.uid).to eq '61889'
    end
  end

  describe '#academic_career_code' do
    it 'returns academic career code' do
      expect(subject.academic_career_code).to eq 'GRAD'
    end
  end

  describe '#academic_program_code' do
    it 'returns academic program code' do
      expect(subject.academic_program_code).to eq 'GACAD'
    end
  end

  describe '#academic_plan_code' do
    it 'returns academic plan code' do
      expect(subject.academic_plan_code).to eq '79249PHDG'
    end
  end

  describe '#requirements' do
    it 'returns requirements' do
      subject.requirements.each do |requirement|
        expect(requirement).to be_an_instance_of User::Academics::DegreeProgress::Graduate::Requirement
      end
    end
    context 'when a requirement has no name' do
      let(:requirement_without_name) do
        {
          name: nil,
          code: 'GARBAGE',
          dateCompleted: '2017-05-24',
          dateAnticipated: '2017-05-24',
          status: 'N',
          effdt: '2017-03-28',
          attempts: [],
        }
      end
      let(:requirements) do
        [
          advancement_to_candidacy_phd_requirement,
          qualifying_exam_results_requirement,
          requirement_without_name,
          qualifying_exam_approval_requirement,
        ]
      end
      it 'excludes requirements with no name' do
        expect(subject.requirements.count).to eq 3
        subject.requirements.each do |requirement|
          expect(requirement.name).to be
        end
      end
    end
  end

  describe '#qualifying_exam_results_requirement' do
    context 'when qualifying exam results requirement does not exist for milestone' do
      let(:requirements) do
        [
          advancement_to_candidacy_phd_requirement,
          qualifying_exam_approval_requirement,
        ]
      end
      it 'returns nil' do
        expect(subject.qualifying_exam_results_requirement).to eq nil
      end
    end
    context 'when qualifying exam results requirement exists for milestone' do
      let(:requirements) do
        [
          advancement_to_candidacy_phd_requirement,
          qualifying_exam_results_requirement,
          qualifying_exam_approval_requirement,
        ]
      end
      it 'returns qualifying exam result requirement' do
        expect(subject.qualifying_exam_results_requirement).to be_an_instance_of User::Academics::DegreeProgress::Graduate::Requirement
        expect(subject.qualifying_exam_results_requirement.code).to eq 'AAGQERESLT'
      end
    end
  end

  describe '#qualifying_exam_approval_requirement' do
    context 'when qualifying exam approval requirement does not exist for milestone' do
      let(:requirements) do
        [
          advancement_to_candidacy_phd_requirement,
          qualifying_exam_results_requirement,
        ]
      end
      it 'returns nil' do
        expect(subject.qualifying_exam_approval_requirement).to eq nil
      end
    end
    context 'when qualifying exam approval requirement exists for milestone' do
      let(:requirements) do
        [
          advancement_to_candidacy_phd_requirement,
          qualifying_exam_results_requirement,
          qualifying_exam_approval_requirement,
        ]
      end
      it 'returns qualifying exam result requirement' do
        expect(subject.qualifying_exam_approval_requirement).to be_an_instance_of User::Academics::DegreeProgress::Graduate::Requirement
        expect(subject.qualifying_exam_approval_requirement.code).to eq 'AAGQEAPRV'
      end
    end
  end

  describe '#as_json' do
    it 'returns hash representation of milestone' do
      result = subject.as_json
      expect(result).to be_an_instance_of Hash
      expect(result[:acadCareer]).to eq 'GRAD'
      expect(result[:acadProgCode]).to eq 'GACAD'
      expect(result[:acadDegreeStatus]).to eq 'AW'
      expect(result[:acadPlan]).to eq 'Education PhD'
      expect(result[:acadProg]).to eq 'Graduate Academic Programs'
      expect(result[:requirements].count).to eq 3
      expect(result[:requirements][0][:name]).to eq 'Advancement to Candidacy'
      expect(result[:requirements][1][:name]).to eq 'Qualifying Exam Results'
      expect(result[:requirements][2][:name]).to eq 'Approval for Qualifying Exam'
    end
  end

end
