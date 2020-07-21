describe User::Academics::Diploma do
  let(:uid) { '61889' }
  let(:campus_solutions_id) { '1234567' }
  let(:current_user_is_student) { true }
  let(:current_user) { double(User::Current, :uid => uid, :campus_solutions_id => campus_solutions_id, :is_student? => current_user_is_student) }
  let(:diploma_sso) { double(sso_url: 'https://www.example.com/sso/') }
  let(:diploma_messages) do
    double({
      :supported_terms => ['2202','2205'],
      :paper_diploma_message => {:messageSetNbr=>'28510', :messageNbr=>'1', :messageText=>'Paper Diploma', :msgSeverity=>'M', :descrlong=>'You will receive an email once your diploma has been sent.'},
      :electronic_diploma_notice_message => {:messageSetNbr=>'28510', :messageNbr=>'2', :messageText=>'Electronic Diploma', :msgSeverity=>'M', :descrlong=>'You will receive an email once your diploma is available for download.'},
      :electronic_diploma_ready_message => {:messageSetNbr=>'28510', :messageNbr=>'3', :messageText=>'Electronic Diploma', :msgSeverity=>'M', :descrlong=>'Your electronic diploma is ready. To download your certified electronic paper diploma, click the button below.'},
      :electronic_diploma_help_message => {:messageSetNbr=>'28510', :messageNbr=>'2205', :messageText=>'eDiploma Summer 2020', :msgSeverity=>'M', :descrlong=>'Test for Summer 2020 Diploma card'},
    })
  end
  subject { described_class.new(current_user) }

  before do
    allow(User::Current).to receive(:new).with(61889).and_return(current_user)
    allow(User::Academics::DiplomaSso).to receive(:new).and_return(diploma_sso)
    allow(User::Academics::DiplomaMessages).to receive(:new).and_return(diploma_messages)
  end

  describe '#show_diploma_eligibility?' do
    context 'user has student plan with degree checkout status eligible for diploma' do
      before { allow(subject).to receive(:has_eligible_degree_checkout_status?).and_return(true) }

      context 'user does not have student plan with awarded degree checkout status' do
        before { allow(subject).to receive(:has_awarded_degree_checkout_status?).and_return(false) }

        context 'user is in degree eligible student group' do
          before { allow(subject).to receive(:user_in_degree_eligible_student_group?).and_return(true) }
          it 'returns true' do
            expect(subject.show_diploma_eligibility?).to eq true
          end
        end

        context 'user is not in degree eligible student group' do
          before { allow(subject).to receive(:user_in_degree_eligible_student_group?).and_return(false) }
          it 'returns false' do
            expect(subject.show_diploma_eligibility?).to eq false
          end
        end
      end
    end

    context 'user does not have student plan with degree checkout status eligible for diploma' do
      before { allow(subject).to receive(:has_eligible_degree_checkout_status?).and_return(false) }

      context 'user has student plan with degree checkout status awarded diploma' do
        before { allow(subject).to receive(:has_awarded_degree_checkout_status?).and_return(true) }
        it 'returns true' do
          expect(subject.show_diploma_eligibility?).to eq true
        end
      end

      context 'user is in degree awarded student group' do
        before { allow(subject).to receive(:user_in_degree_awarded_student_group?).and_return(true) }
      end
    end
  end

  describe '#as_json' do
    it 'returns sso url' do
      expect(subject.as_json[:ssoUrl]).to eq 'https://www.example.com/sso/'
    end
    it 'returns paper diploma help message' do
      expect(subject.as_json[:paperDiplomaMessage][:messageText]).to eq 'Paper Diploma'
    end
    it 'returns electronic diploma notice message' do
      expect(subject.as_json[:electronicDiplomaNoticeMessage][:messageNbr]).to eq '2'
      expect(subject.as_json[:electronicDiplomaNoticeMessage][:messageText]).to eq 'Electronic Diploma'
    end
    it 'returns electronic diploma ready message' do
      expect(subject.as_json[:electronicDiplomaReadyMessage][:messageNbr]).to eq '3'
      expect(subject.as_json[:electronicDiplomaReadyMessage][:messageText]).to eq 'Electronic Diploma'
    end
    it 'returns greatest supported term message for electronic diploma help' do
      expect(subject.as_json[:electronicDiplomaHelpMessage][:messageText]).to eq 'eDiploma Summer 2020'
    end
  end

  describe '#supported_terms' do
    it 'returns configured term ids supported in ce-diploma' do
      expect(subject.supported_terms).to eq ['2202','2205']
    end
  end

  describe '#expected_graduation_terms' do
    let(:active_or_completed_student_plans) do
      [
        double(:expected_graduation_term_id => '2202'),
        double(:expected_graduation_term_id => '2205'),
      ]
    end
    before { allow(subject).to receive(:active_or_completed_student_plans).and_return(active_or_completed_student_plans) }
    it 'returns graduation terms for active or completed plans' do
      expect(subject.expected_graduation_terms).to eq ['2202', '2205']
    end
  end

  describe '#active_or_completed_student_plans' do
    let(:academic_statuses) do
      [
        double(active_student_plans: ['student_plan1'], completed_student_plans: ['student_plan2']),
        double(active_student_plans: ['student_plan3'], completed_student_plans: ['student_plan4']),
      ]
    end
    let(:hub_edos_academic_statuses) { double(:all => academic_statuses) }
    before { allow(HubEdos::StudentApi::V2::Student::AcademicStatuses).to receive(:new).and_return(hub_edos_academic_statuses) }
    it 'returns flattened array of active student plans sourced from each academic status' do
      expect(subject.active_or_completed_student_plans).to eq ['student_plan1', 'student_plan2', 'student_plan3', 'student_plan4']
    end
  end

  describe '#user_in_degree_awarded_student_group?' do
    let(:degree_awarded_type_descriptor) { double(code: 'RDGA', description: 'Degree Awarded')}
    let(:degree_awarded_student_attribute) { double(:type_code => 'RDGA', :type => degree_awarded_type_descriptor) }
    before { allow(HubEdos::StudentApi::V2::Student::StudentAttributes).to receive(:new).and_return(student_attributes) }
    context 'when no attributes returned' do
      let(:student_attributes) { double(find_all_by_type_code: []) }
      it 'returns false' do
        expect(subject.user_in_degree_awarded_student_group?).to eq false
      end
    end
    context 'when no attributes returned' do
      let(:student_attributes) { double(find_all_by_type_code: [degree_awarded_student_attribute]) }
      it 'returns true' do
        expect(subject.user_in_degree_awarded_student_group?).to eq true
      end
    end
  end

  describe '#user_in_degree_eligible_student_group?' do
    let(:degree_eligible_type_descriptor) { double(code: 'RDGE', description: 'Degree Eligible')}
    let(:degree_eligible_student_attribute) { double(:type_code => 'RDGE', :type => degree_eligible_type_descriptor) }
    before { allow(HubEdos::StudentApi::V2::Student::StudentAttributes).to receive(:new).and_return(student_attributes) }
    context 'when no attributes returned' do
      let(:student_attributes) { double(find_all_by_type_code: []) }
      it 'returns false' do
        expect(subject.user_in_degree_eligible_student_group?).to eq false
      end
    end
    context 'when no attributes returned' do
      let(:student_attributes) { double(find_all_by_type_code: [degree_eligible_student_attribute]) }
      it 'returns true' do
        expect(subject.user_in_degree_eligible_student_group?).to eq true
      end
    end
  end

  describe '#eligible_student_plans' do
    let(:supported_terms) { ['2202','2205'] }
    let(:student_plan_spring_2019) { double(expected_graduation_term_id: '2192') }
    let(:student_plan_fall_2019) { double(expected_graduation_term_id: '2198') }
    let(:student_plan_spring_2020) { double(expected_graduation_term_id: '2202') }
    before do
      allow(subject).to receive(:supported_terms).and_return(supported_terms)
      allow(subject).to receive(:active_or_completed_student_plans).and_return(active_or_completed_student_plans)
    end
    context 'when supported student plan is present' do
      let(:active_or_completed_student_plans) { [student_plan_spring_2020, student_plan_fall_2019] }
      it 'returns eligible student plan' do
        expect(subject.eligible_student_plans.count).to eq 1
      end
    end
    context 'when supported student plans are not present' do
      let(:active_or_completed_student_plans) { [student_plan_spring_2019, student_plan_fall_2019] }
      it 'returns eligible student plan' do
        expect(subject.eligible_student_plans).to be_an_instance_of Array
        expect(subject.eligible_student_plans.count).to eq 0
      end
    end
  end
end
