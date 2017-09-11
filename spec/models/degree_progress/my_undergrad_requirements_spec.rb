describe DegreeProgress::MyUndergradRequirements do

  let(:user_id) { random_id }
  let(:emplid) { random_id }
  let(:academic_status_letters_and_science_program) do
    {
      :feed => {
        'student' => {
          'roles' => {
            'lettersAndScience' => true
          }
        }
      }
    }
  end
  let(:academic_status_generic_program) do
    {
      :feed => {
        'student' => {
          'roles' => {}
        }
      }
    }
  end
  before do
    proxy_class = CampusSolutions::DegreeProgress::UndergradRequirements
    fake_proxy = proxy_class.new(user_id: user_id, fake: true)
    allow(proxy_class).to receive(:new).and_return fake_proxy
    allow(Settings.features).to receive(flag).and_return(true)
  end

  describe '#get_feed_internal' do
    let(:flag) { :cs_degree_progress_ugrd_student }
    subject { described_class.new(user_id).get_feed_internal }

    it_behaves_like 'a proxy that observes a feature flag'
    it_behaves_like 'a proxy that returns undergraduate milestone data'

    context 'when student is active in the Letters and Science program' do
      before do
        allow_any_instance_of(HubEdos::MyAcademicStatus).to receive(:get_feed).and_return(academic_status_letters_and_science_program)
      end
      it 'includes the Academic Progress Report link in the response' do
        expect(subject[:feed][:links]).to be
        expect(subject[:feed][:links][:academicProgressReport]).to be
        expect(subject[:feed][:links][:academicProgressReport][:url]).to eq 'https://bcswebqat.is.berkeley.edu/psp/bcsqat/EMPLOYEE/PSFT_CS/c/SA_LEARNER_SERVICES.SAA_SS_DPR_ADB.GBL?EMPLID=25738808'
      end
    end
    context 'when student is not active in the Letters and Science program' do
      before do
        allow_any_instance_of(HubEdos::MyAcademicStatus).to receive(:get_feed).and_return(academic_status_generic_program)
      end
      it 'does not include the Academic Progress Report link in the response' do
        expect(subject[:feed][:links]).not_to be
      end
    end

  end
end
