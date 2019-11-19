describe User::Academics::DegreeProgress::Graduate::StudentLinks do
  subject { described_class.new(user) }
  let(:uid) { '61889' }
  let(:user) { User::Current.new(uid) }
  let(:current_user_roles) { [] }
  let(:user_academic_roles) { double(current_user_roles: current_user_roles) }
  before { allow(User::Academics::Roles).to receive(:new).with(user).and_return(user_academic_roles) }


  describe '#links' do
    let(:apr_haas_student) { false }
    let(:apr_law_student) { false }
    let(:apr_non_haas_grad_student) { false }
    before do
      allow(subject).to receive(:apr_haas_student?).and_return(apr_haas_student)
      allow(subject).to receive(:apr_law_student?).and_return(apr_law_student)
      allow(subject).to receive(:apr_non_haas_grad_student?).and_return(apr_non_haas_grad_student)
    end
    context 'when student can view haas student apr link' do
      let(:apr_haas_student) { true }
      it 'returns haas APR link' do
        expect(subject.links[:academic_progress_report_haas]).to be
        expect(subject.links[:academic_progress_report_law]).to_not be
        expect(subject.links[:academic_progress_report_grad]).to_not be
      end
    end
    context 'when student can view law student apr link' do
      let(:apr_law_student) { true }
      it 'returns haas APR link' do
        expect(subject.links[:academic_progress_report_haas]).to_not be
        expect(subject.links[:academic_progress_report_law]).to be
        expect(subject.links[:academic_progress_report_grad]).to_not be
      end
    end
    context 'when student can view grad student apr link' do
      let(:apr_non_haas_grad_student) { true }
      it 'returns haas APR link' do
        expect(subject.links[:academic_progress_report_haas]).to_not be
        expect(subject.links[:academic_progress_report_law]).to_not be
        expect(subject.links[:academic_progress_report_grad]).to be
      end
    end

  end

  # def links
  #   links = {}
  #   links[:academic_progress_report_haas] = academic_progress_report_haas_link if apr_haas_student?
  #   links[:academic_progress_report_law] = academic_progress_report_law_link if apr_law_student?
  #   links[:academic_progress_report_grad] = academic_progress_report_grad_link if apr_non_haas_grad_student?
  # end

  # def academic_progress_report_haas_link
  #   LinkFetcher.fetch_link(APR_LINK_ID_HAAS, { :EMPLID => user.campus_solutions_id })
  # end

  # def academic_progress_report_law_link
  #   LinkFetcher.fetch_link(APR_LINK_ID_LAW, { :EMPLID => user.campus_solutions_id })
  # end

  # def academic_progress_report_grad
  #   LinkFetcher.fetch_link(APR_LINK_ID_GRAD, { :EMPLID => user.campus_solutions_id })
  # end

  describe '#current_user_roles' do
    let(:current_user_roles) { [:ugrd, :lettersAndScience] }
    it 'returns current user roles' do
      expect(subject.current_user_roles).to eq [:ugrd, :lettersAndScience]
    end
  end

  describe '#apr_haas_student?' do
    context 'when user is currently an active haas business masters student' do
      let(:current_user_roles) { [:haasBusinessAdminMasters, :grad] }
      it 'returns true' do
        expect(subject.apr_haas_student?).to eq true
      end
    end
    context 'when user is currently an active haas business admin phd student' do
      let(:current_user_roles) { [:haasBusinessAdminPhD, :grad] }
      it 'returns true' do
        expect(subject.apr_haas_student?).to eq true
      end
    end
    context 'when user is not currently an active haas business student' do
      let(:current_user_roles) { [:grad] }
      it 'returns false' do
        expect(subject.apr_haas_student?).to eq false
      end
    end
  end

  describe '#apr_law_student?' do
    context 'when user is currently an active doctor science law student' do
      let(:current_user_roles) { [:doctorScienceLaw, :grad] }
      it 'returns true' do
        expect(subject.apr_law_student?).to eq true
      end
    end
    context 'when user is currently an active juris social policy masters student' do
      let(:current_user_roles) { [:jurisSocialPolicyMasters, :grad] }
      it 'returns true' do
        expect(subject.apr_law_student?).to eq true
      end
    end
    context 'when user is currently an active juris social policy phc student' do
      let(:current_user_roles) { [:jurisSocialPolicyPhC, :grad] }
      it 'returns true' do
        expect(subject.apr_law_student?).to eq true
      end
    end
    context 'when user is currently an active juris social policy phd student' do
      let(:current_user_roles) { [:jurisSocialPolicyPhD, :grad] }
      it 'returns true' do
        expect(subject.apr_law_student?).to eq true
      end
    end
    context 'when user is currently an active Law JD/CDP student' do
      let(:current_user_roles) { [:lawJdCdp, :grad] }
      it 'returns true' do
        expect(subject.apr_law_student?).to eq true
      end
    end
    context 'when user is currently an active Master of Laws LLM student' do
      let(:current_user_roles) { [:masterOfLawsLlm, :grad] }
      it 'returns true' do
        expect(subject.apr_law_student?).to eq true
      end
    end
    context 'when user is not a law student' do
      let(:current_user_roles) { [:grad] }
      it 'returns false' do
        expect(subject.apr_law_student?).to eq false
      end
    end
  end

  describe '#apr_non_haas_grad_student?' do
    context 'when user is a grad student' do
      before { current_user_roles << :grad }
      it 'returns true' do
        expect(subject.apr_non_haas_grad_student?).to eq true
      end
      context 'when user is a Haas Business Admin Masters student' do
        before { current_user_roles << :haasBusinessAdminMasters }
        it 'returns false' do
          expect(subject.apr_non_haas_grad_student?).to eq false
        end
      end
      context 'when user is a Haas Business Admin PhD student' do
        before { current_user_roles << :haasBusinessAdminPhD }
        it 'returns false' do
          expect(subject.apr_non_haas_grad_student?).to eq false
        end
      end
      context 'when user is a Haas Full Time MBA student' do
        before { current_user_roles << :haasFullTimeMba }
        it 'returns false' do
          expect(subject.apr_non_haas_grad_student?).to eq false
        end
      end
      context 'when user is a Haas Evening and Weekend MBA student' do
        before { current_user_roles << :haasEveningWeekendMba }
        it 'returns false' do
          expect(subject.apr_non_haas_grad_student?).to eq false
        end
      end
      context 'when user is a Haas Executive MBA student' do
        before { current_user_roles << :haasExecMba }
        it 'returns false' do
          expect(subject.apr_non_haas_grad_student?).to eq false
        end
      end
      context 'when user is a Haas Masters of Financial Engineering student' do
        before { current_user_roles << :haasMastersFinEng }
        it 'returns false' do
          expect(subject.apr_non_haas_grad_student?).to eq false
        end
      end
      context 'when user is a Haas MBA in Public Health student' do
        before { current_user_roles << :haasMbaPublicHealth }
        it 'returns false' do
          expect(subject.apr_non_haas_grad_student?).to eq false
        end
      end
      context 'when user is a Haas MBA Juris Doctor student' do
        before { current_user_roles << :haasMbaJurisDoctor }
        it 'returns false' do
          expect(subject.apr_non_haas_grad_student?).to eq false
        end
      end
    end
    context 'when user is not a grad student' do
      before { current_user_roles << :ugrd }
      it 'returns false' do
        expect(subject.apr_non_haas_grad_student?).to eq false
      end
    end
  end
end
