describe User::Academics::DegreeProgress::Graduate::Requirement do
  subject { described_class.new(data, parent_milestone, user) }
  let(:user) { User::Current.new('61889') }
  let(:requirement_code) { 'AAGADVPHD' }
  let(:status_code) { 'N' }
  let(:date_completed) { '2016-12-16' }
  let(:date_anticipated) { '2016-12-28' }
  let(:data) do
    {
      name: 'Advancement to Candidacy PhD',
      code: requirement_code,
      dateCompleted: date_completed,
      dateAnticipated: date_anticipated,
      status: status_code,
      effdt: '2017-03-26',
      attempts: [
        {
          attemptNbr: '1',
          attemptDate: '2016-12-16',
          attemptStatus: 'P',
          effdt: '2017-03-26'
        }
      ]
    }
  end
  let(:qe_results_requirement_attempts) { [] }
  let(:qe_results_requirement) { double(attempts: qe_results_requirement_attempts) }
  let(:parent_milestone) { double(qualifying_exam_results_requirement: qe_results_requirement, academic_plan_code: '79249PHDG') }
  let(:candidacy_term_statuses) { nil }
  before { allow(User::Academics::DegreeProgress::Graduate::CandidacyTermStatuses).to receive(:new).and_return(candidacy_term_statuses) }

  describe '#code' do
    it 'returns code' do
      expect(subject.code).to eq 'AAGADVPHD'
    end
    context 'when code has spaces' do
      let(:requirement_code) { '   AAGADVPHD ' }
      it 'returns code without spaces' do
        expect(subject.code).to eq 'AAGADVPHD'
      end
    end
    context 'when code is lowercase' do
      let(:requirement_code) { 'aagadvphd' }
      it 'returns code in uppercase' do
        expect(subject.code).to eq 'AAGADVPHD'
      end
    end
    context 'when code is not a string' do
      let(:requirement_code) { 500555 }
      it 'returns as string' do
        expect(subject.code).to eq '500555'
      end
    end
  end

  describe '#status_code' do
    context 'when status code present' do
      let(:status_code) { 'N' }
      it 'returns status code' do
        expect(subject.status_code).to eq 'N'
      end
    end
    context 'when status code not present' do
      let(:status_code) { nil }
      it 'returns status code of latest attempt' do
        expect(subject.status_code).to eq 'P'
      end
    end
  end

  describe '#order_number' do
    it 'returns order number based on code' do
      expect(subject.order_number).to eq 3
    end
  end

  describe '#status_description' do
    context 'when requirement has known status code' do
      let(:status_code) { 'Y' }
      it 'returns status description based on code and status code' do
        expect(subject.status_description).to eq 'Completed'
      end
    end
    context 'when requirement has known status code' do
      let(:status_code) { '$' }
      it 'returns incomplete status description' do
        expect(subject.status_description).to eq 'Not Satisfied'
      end
    end
  end

  describe '#name' do
    it 'returns description based on code' do
      expect(subject.name).to eq 'Advancement to Candidacy'
    end
  end

  describe '#form_notification' do
    let(:status_code) { 'N' }
    context 'when qualifying exam approval milestone' do
      let(:requirement_code) { Berkeley::GraduateMilestones::QE_APPROVAL_MILESTONE }
      it 'returns form required notification string' do
        expect(subject.form_notification).to eq '(Form Required)'
      end
    end
    context 'when advancement to candidacy thesis plan' do
      let(:requirement_code) { 'AAGADVMAS1' }
      it 'returns form required notification string' do
        expect(subject.form_notification).to eq '(Form Required)'
      end
    end
    context 'when requirement is completed' do
      let(:status_code) { 'Y' }
      it 'returns nil' do
        expect(subject.form_notification).to eq nil
      end
    end
    context 'when requirement code unknown' do
      let(:requirement_code) { 'ABCDEFG' }
      it 'returns nil' do
        expect(subject.form_notification).to eq nil
      end
    end
  end

  describe '#milestone_academic_plan_code' do
    context 'when milestone is not present' do
      let(:parent_milestone) { nil }
      it 'returns nil' do
        expect(subject.milestone_academic_plan_code).to eq nil
      end
    end
    context 'when milestone is present' do
      let(:parent_milestone) { double(academic_plan_code: '79249PHDG') }
      it 'returns the parent milestones academic plan code' do
        expect(subject.milestone_academic_plan_code).to eq '79249PHDG'
      end
    end
  end

  describe '#date_completed' do
    it 'returns date completed' do
      expect(subject.date_completed).to be_an_instance_of DateTime
      expect(subject.date_completed.to_s).to eq '2016-12-16T00:00:00-08:00'
    end
  end

  describe '#date_completed_formatted' do
    let(:date_completed) { '2016-12-16' }
    it 'returns formatted date completed' do
      expect(subject.date_completed_formatted).to eq 'Dec 16, 2016'
    end
    context 'when date completed is not present' do
      let(:date_completed) { nil }
      it 'returns empty string' do
        expect(subject.date_completed_formatted).to eq ''
      end
    end
  end

  describe '#date_anticipated' do
    it 'returns date anticipated' do
      expect(subject.date_anticipated).to be_an_instance_of DateTime
      expect(subject.date_anticipated.to_s).to eq '2016-12-28T00:00:00-08:00'
    end
  end

  describe '#date_anticipated_formatted' do
    let(:date_anticipated) { '2016-12-28' }
    it 'returns formatted date anticipated' do
      expect(subject.date_anticipated_formatted).to eq 'Dec 28, 2016'
    end
    context 'when date anticipated is not present' do
      let(:date_anticipated) { nil }
      it 'returns empty string' do
        expect(subject.date_anticipated_formatted).to eq ''
      end
    end
  end

  describe '#attempts' do
    it 'returns attempts' do
      result = subject.attempts
      expect(result.count).to eq 1
      expect(result[0]).to be_an_instance_of User::Academics::DegreeProgress::Graduate::Attempt
      expect(result[0])
    end
  end

  describe '#qualifying_exam_approval?' do
    context 'when requirement is not a qualifying exam approval requirement' do
      let(:requirement_code) { 'AAGADVPHD' }
      it 'returns false' do
        expect(subject.qualifying_exam_approval?).to eq false
      end
    end
    context 'when requirement is a qualifying exam approval requirement' do
      let(:requirement_code) { 'AAGQEAPRV' }
      it 'returns true' do
        expect(subject.qualifying_exam_approval?).to eq true
      end
    end
  end

  describe '#qualifying_exam_results?' do
    context 'when requirement is qualifying exam results milestone' do
      let(:requirement_code) { 'AAGQERESLT' }
      it 'returns true' do
        expect(subject.qualifying_exam_results?).to eq true
      end
    end
    context 'when requirement is NOT qualifying exam results milestone' do
      let(:requirement_code) { 'AAGQEAPRV' }
      it 'returns true' do
        expect(subject.qualifying_exam_results?).to eq false
      end
    end
  end

  describe '#completed?' do
    context 'when requirement is not completed' do
      let(:status_code) { 'N' }
      it 'returns false' do
        expect(subject.completed?).to eq false
      end
    end
    context 'when requirement is completed' do
      let(:status_code) { 'Y' }
      it 'returns true' do
        expect(subject.completed?).to eq true
      end
    end
  end

  describe '#advancement_to_candidacy?' do
    let(:requirement_code) { 'AAGQERESLT' }
    context 'when code is not AAGADVPHD' do
      it 'returns false' do
        expect(subject.advancement_to_candidacy?).to eq false
      end
    end
    context 'when code is AAGADVPHD' do
      let(:requirement_code) { 'AAGADVPHD' }
      it 'returns true' do
        expect(subject.advancement_to_candidacy?).to eq true
      end
    end
  end

  describe '#candidacy_term_status' do
    let(:status_code) { 'N' }
    context 'when not completed' do
      it 'returns nil' do
        expect(subject.candidacy_term_status).to eq nil
      end
    end
    context 'when not an advancement to candidacy requirement' do
      let(:requirement_code) { 'AAGADVMAS1' }
      it 'returns nil' do
        expect(subject.candidacy_term_status).to eq nil
      end
    end
    context 'when a completed advancement to candidacy requirement' do
      let(:status_code) { 'Y' }
      let(:requirement_code) { 'AAGADVPHD' }
      context 'when candidacy term statuses not present for user' do
        let(:candidacy_term_statuses) { double(all: nil) }
        it 'returns nil' do
          expect(subject.candidacy_term_status).to eq nil
        end
      end
      context 'when candidacy term statuses present for user' do
        let(:candidacy_term_statuses) { double(all: all_candidacy_term_statuses) }
        context 'when candidacy term statuses do not match milestone academic term code' do
          let(:all_candidacy_term_statuses) { [double(academic_plan_code: 'ABCDEFG')] }
          it 'returns nil' do
            expect(subject.candidacy_term_status).to eq nil
          end
        end
        context 'when candidacy term statuses match milestone academic term code' do
          let(:all_candidacy_term_statuses) { [double(academic_plan_code: '79249PHDG')] }
          it 'returns candidacy term status' do
            result = subject.candidacy_term_status
            expect(result.academic_plan_code).to eq '79249PHDG'
          end
        end
      end
    end
  end

  describe '#qualifying_exam_attempted?' do
    context 'when parent milestone has qualifying exam results requirement with attempts' do
      let(:qe_results_requirement_attempts) { ['Atempt 1', 'Attempt 2'] }
      it 'returns true' do
        expect(subject.qualifying_exam_attempted?).to eq true
      end
    end
    context 'when parent milestone has qualifying exam results requirement without attempts' do
      let(:qe_results_requirement_attempts) { [] }
      it 'returns false' do
        expect(subject.qualifying_exam_attempted?).to eq false
      end
    end
  end

  describe '#proposed_exam_date' do
    context 'when not a qualifying exam approval requirement' do
      let(:requirement_code) { 'AAGQERESLT' }
      it 'returns nil' do
        expect(subject.proposed_exam_date).to eq nil
      end
    end
    context 'when not completed' do
      let(:status_code) { 'N' }
      it 'returns nil' do
        expect(subject.proposed_exam_date).to eq nil
      end
    end
    context 'when qualifying exam results requirement has attempts' do
      let(:qe_results_requirement_attempts) { ['Atempt 1', 'Attempt 2'] }
      it 'returns nil' do
        expect(subject.proposed_exam_date).to eq nil
      end
    end
    context 'when a completed qualifying exam approval without qualifying exam result attempts' do
      let(:status_code) { 'Y' }
      let(:requirement_code) { 'AAGQEAPRV' }
      let(:qe_results_requirement_attempts) { [] }
      it 'returns date anticipated' do
        expect(subject.proposed_exam_date.to_s).to eq 'Dec 28, 2016'
      end
    end
  end

  describe '#as_json' do
    it 'returns hash representing requirement' do
      result = subject.as_json
      expect(result).to be_an_instance_of Hash
      expect(result[:name]).to eq 'Advancement to Candidacy'
      expect(result[:code]).to eq 'AAGADVPHD'
      expect(result[:status]).to eq 'Not Satisfied'
      expect(result[:orderNumber]).to eq 3
      expect(result[:dateCompleted]).to eq "Dec 16, 2016"
      expect(result[:dateAnticipated]).to eq "Dec 28, 2016"
      expect(result[:formNotification]).to eq nil
      expect(result[:attempts].count).to eq 0
      expect(result[:proposedExamDate]).to eq nil
    end
    context 'when qualifying exam attempts present' do
      let(:requirement_code) { 'AAGQERESLT' }
      it 'includes hash attempts' do
        result = subject.as_json
        expect(result[:attempts].count).to eq 1
        expect(result[:attempts].first[:statusCode]).to eq 'P'
        expect(result[:attempts].first[:display]).to eq 'Exam 1: Passed Dec 16, 2016'
      end
    end
    context 'when candidacy term status is not applicable to requirement' do
      it 'does not include candidacay term status' do
        result = subject.as_json
        expect(result.has_key?(:candidacyTermStatus)).to eq false
      end
    end
    context 'when candidacy term status is applicable to requirement' do
      let(:candidacy_term_status_hash) { {academicCareerCode: 'GRAD'} }
      let(:candidacy_term_status) { double(:candidacy_term_status, {academic_plan_code: '79249PHDG', as_json: candidacy_term_status_hash}) }
      before { allow(subject).to receive(:candidacy_term_status).and_return(candidacy_term_status) }
      it 'includes candidacay term status' do
        result = subject.as_json
        expect(result[:candidacyTermStatus][:academicCareerCode]).to eq 'GRAD'
      end
    end
  end
end
