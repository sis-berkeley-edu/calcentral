describe DegreeProgress::MyUndergradRequirements do
  subject { described_class.new(user_id) }
  let(:emplid) { 11667051 }
  let(:user_id) { 61889 }
  let(:feature_flag_enabled) { true }
  before do
    proxy_class = CampusSolutions::DegreeProgress::UndergradRequirements
    fake_proxy = proxy_class.new(user_id: user_id, fake: true)
    allow(proxy_class).to receive(:new).and_return fake_proxy
    allow(Settings.features).to receive(:cs_degree_progress_ugrd_student).and_return(feature_flag_enabled)
  end

  describe '#get_feed_internal' do
    let(:flag) { :cs_degree_progress_ugrd_student }
    subject { described_class.new(user_id).get_feed_internal }

    it_behaves_like 'a proxy that observes a feature flag'
    it_behaves_like 'a proxy that returns undergraduate milestone data'

    context 'when student is active in the Letters and Science program' do
      before do
        allow_any_instance_of(MyAcademics::MyAcademicRoles).to receive(:get_feed).and_return(academic_roles)
      end
      let(:academic_roles) do
        {
          current: { 'lettersAndScience' => true }
        }
      end
      it 'includes the Academic Progress Report link in the response' do
        expect(subject[:feed][:links]).to be
        expect(subject[:feed][:links][:academicProgressReport]).to be
        expect(subject[:feed][:links][:academicProgressReport][:url]).to eq 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/PSFT_CS/c/SA_LEARNER_SERVICES.SAA_SS_DPR_ADB.GBL?EMPLID=11667051'
      end
    end
    context 'when student is active in the Undergraduate College of Engineering' do
      before do
        allow_any_instance_of(MyAcademics::MyAcademicRoles).to receive(:get_feed).and_return(academic_roles)
      end
      let(:academic_roles) do
        {
          current: { 'ugrdEngineering' => true }
        }
      end
      it 'includes the Academic Progress Report link in the response' do
        expect(subject[:feed][:links]).to be
        expect(subject[:feed][:links][:academicProgressReport]).to be
        expect(subject[:feed][:links][:academicProgressReport][:url]).to eq 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/PSFT_CS/c/SA_LEARNER_SERVICES.SAA_SS_DPR_ADB.GBL?EMPLID=11667051'
      end
    end
    context 'when student is active in the Undergraduate Environmental Design program' do
      before do
        allow_any_instance_of(MyAcademics::MyAcademicRoles).to receive(:get_feed).and_return(academic_roles)
      end
      let(:academic_roles) do
        {
          current: { 'ugrdEnvironmentalDesign' => true }
        }
      end
      it 'does includes the Academic Progress Report link in the response' do
        expect(subject[:feed][:links][:academicProgressReport]).to be
        expect(subject[:feed][:links][:academicProgressReport][:url]).to eq 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/PSFT_CS/c/SA_LEARNER_SERVICES.SAA_SS_DPR_ADB.GBL?EMPLID=11667051'
      end
    end
    context 'when student is not active in the Letters and Science program' do
      before do
        allow_any_instance_of(MyAcademics::MyAcademicRoles).to receive(:get_feed).and_return(academic_roles)
      end
      let(:academic_roles) do
        {
          current: { 'lettersAndScience' => false }
        }
      end
      it 'does not include the Academic Progress Report link in the response' do
        expect(subject[:feed][:links]).not_to be
      end
    end

  end

  describe '#should_see_links?' do
    let(:result) { subject.should_see_links? }
    let(:roles_feed) do
      {
        current: {
          'lettersAndScience' => ugrd_ls_role_present,
          'ugrdEngineering' => ugrd_eng_role_present,
          'ugrdEnvironmentalDesign' => ugrd_env_role_present,
          'ugrdHaasBusiness' => ugrd_haas_bus_role_present,
        }
      }
    end
    let(:ugrd_ls_role_present) { false }
    let(:ugrd_eng_role_present) { false }
    let(:ugrd_env_role_present) { false }
    let(:ugrd_haas_bus_role_present) { false }
    let(:my_academic_roles) { double(:get_feed => roles_feed) }
    before { allow(MyAcademics::MyAcademicRoles).to receive(:new).and_return(my_academic_roles) }
    context 'when student has no matching role' do
      it 'returns false' do
        expect(result).to eq false
      end
    end
    context 'when student is in undergraduate letters and science program' do
      let(:ugrd_ls_role_present) { true }
      it 'returns true' do
        expect(result).to eq true
      end
    end
    context 'when student is in undergraduate engineering program' do
      let(:ugrd_eng_role_present) { true }
      it 'returns true' do
        expect(result).to eq true
      end
    end
    context 'when student is in undergraduate environmental design program' do
      let(:ugrd_env_role_present) { true }
      it 'returns true' do
        expect(result).to eq true
      end
    end
    context 'when student is in undergraduate haas business program' do
      let(:ugrd_haas_bus_role_present) { true }
      it 'returns true' do
        expect(result).to eq true
      end
    end
  end

end
