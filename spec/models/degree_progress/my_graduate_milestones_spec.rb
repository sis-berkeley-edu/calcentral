describe DegreeProgress::MyGraduateMilestones do

  shared_examples 'a proxy that returns a link to the Grad Academic Progress Report' do
    it 'includes said link in the response' do
      expect(subject[:feed][:links]).to be
      expect(subject[:feed][:links][:academicProgressReportGrad]).to be
      expect(subject[:feed][:links][:academicProgressReportGrad][:urlId]).to eq 'UC_CX_APR_RPT_GRD_STDNT'
      expect(subject[:feed][:links][:academicProgressReportGrad][:url]).to eq 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/PSFT_CS/c/SA_LEARNER_SERVICES.SAA_SS_DPR_ADB.GBL?EMPLID=25738808'
    end
  end
  shared_examples 'a proxy that returns a link to the Haas Academic Progress Report' do
    it 'includes said link in the response' do
      expect(subject[:feed][:links]).to be
      expect(subject[:feed][:links][:academicProgressReportHaas]).to be
      expect(subject[:feed][:links][:academicProgressReportHaas][:urlId]).to eq 'UC_CX_APR_RPT_GRD_STDNT_HAAS'
      expect(subject[:feed][:links][:academicProgressReportHaas][:url]).to eq 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/PSFT_CS/c/SA_LEARNER_SERVICES.SAA_SS_DPR_ADB.GBL?EMPLID=25738808'
    end
  end
  shared_examples 'a proxy that returns a link to the Law Academic Progress Report' do
    it 'includes said link in the response' do
      expect(subject[:feed][:links]).to be
      expect(subject[:feed][:links][:academicProgressReportLaw]).to be
      expect(subject[:feed][:links][:academicProgressReportLaw][:urlId]).to eq 'UC_CX_APR_RPT_GRD_STDNT_LAW'
      expect(subject[:feed][:links][:academicProgressReportLaw][:url]).to eq 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/PSFT_CS/c/SA_LEARNER_SERVICES.SAA_SS_DPR_ADB.GBL?EMPLID=25738808'
    end
  end
  shared_examples 'a proxy that returns two links' do
    it 'include exactly two links in the response' do
      expect(subject[:feed][:links].count).to eq 2
    end
  end
  shared_examples 'a proxy that returns one link' do
    it 'include exactly link in the response' do
      expect(subject[:feed][:links].count).to eq 1
    end
  end
  shared_examples 'a proxy that does not return links' do
    it 'does not include a link in the response' do
      expect(subject[:feed][:links].count).to eq 0
    end
  end

  let(:model) { described_class.new(user_id) }
  let(:user_id) { '12345' }
  let(:link_proxy) { CampusSolutions::Link.new(fake: true) }
  let(:user_attributes) do
    {
      roles: {student: true, graduate: graduate_student, law: law_student}
    }
  end
  let(:academic_roles) do
    {
      'jurisSocialPolicyMasters' => whitelisted_law_student,
      'haasBusinessAdminMasters' => whitelisted_haas_student,
      'haasExecMba' => blacklisted_haas_student,
      'grad' => graduate_student,
      'law' => law_student,
    }
  end
  let(:graduate_student) { false }
  let(:law_student) { false }
  let(:whitelisted_law_student) { false }
  let(:whitelisted_haas_student) { false }
  let(:blacklisted_haas_student) { false }

  before do
    allow(User::AggregatedAttributes).to receive(:new).with(user_id).and_return double(get_feed: user_attributes)
    allow(CampusSolutions::Link).to receive(:new).and_return link_proxy
    allow_any_instance_of(MyAcademics::MyAcademicRoles).to receive(:get_feed).and_return(academic_roles)
  end

  describe '#get_feed_internal' do
    subject { model.get_feed_internal }

    context 'when user is a graduate student' do
      let(:graduate_student) { true }

      it_behaves_like 'a proxy that returns graduate milestone data'
      it_behaves_like 'a proxy that properly observes the graduate degree progress for student feature flag'
      it_behaves_like 'a proxy that returns one link'
      it_behaves_like 'a proxy that returns a link to the Grad Academic Progress Report'

      context 'when student is active in an APR-ready Haas plan' do
        let(:whitelisted_haas_student) { true }

        it_behaves_like 'a proxy that returns graduate milestone data'
        it_behaves_like 'a proxy that properly observes the graduate degree progress for student feature flag'
        it_behaves_like 'a proxy that returns one link'
        it_behaves_like 'a proxy that returns a link to the Haas Academic Progress Report'
      end

      context 'when student is active in a Haas plan that doesn\t use the APR' do
        let(:blacklisted_haas_student) { true }

        it_behaves_like 'a proxy that returns graduate milestone data'
        it_behaves_like 'a proxy that properly observes the graduate degree progress for student feature flag'
        it_behaves_like 'a proxy that does not return links'
      end
    end

    context 'when user is a law student' do
      let(:law_student) { true }

      it_behaves_like 'a proxy that returns graduate milestone data'
      it_behaves_like 'a proxy that properly observes the graduate degree progress for student feature flag'
      it_behaves_like 'a proxy that does not return links'

      context 'when student is active in an APR-ready law plan' do
        let(:whitelisted_law_student) { true }

        it_behaves_like 'a proxy that returns graduate milestone data'
        it_behaves_like 'a proxy that properly observes the graduate degree progress for student feature flag'
        it_behaves_like 'a proxy that returns one link'
        it_behaves_like 'a proxy that returns a link to the Law Academic Progress Report'
      end
    end

    context 'when user has both Graduate and Law careers' do
      let(:graduate_student) { true }
      let(:law_student) { true }

      it_behaves_like 'a proxy that returns graduate milestone data'
      it_behaves_like 'a proxy that properly observes the graduate degree progress for student feature flag'
      it_behaves_like 'a proxy that returns one link'
      it_behaves_like 'a proxy that returns a link to the Grad Academic Progress Report'

      context 'when student is active in an APR-ready law plan' do
        let(:whitelisted_law_student) { true }

        it_behaves_like 'a proxy that returns graduate milestone data'
        it_behaves_like 'a proxy that properly observes the graduate degree progress for student feature flag'
        it_behaves_like 'a proxy that returns two links'
        it_behaves_like 'a proxy that returns a link to the Law Academic Progress Report'
        it_behaves_like 'a proxy that returns a link to the Grad Academic Progress Report'
      end
    end

    context 'when user is neither Graduate nor Law' do
      let(:graduate_student) { false }
      let(:law_student) { false }

      it 'returns an empty response' do
        expect(subject).to eq({})
      end
    end
  end
end
