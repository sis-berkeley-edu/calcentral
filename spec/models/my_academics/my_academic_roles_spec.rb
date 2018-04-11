describe MyAcademics::MyAcademicRoles do

  before do
    fake_proxy = HubEdos::AcademicStatus.new(fake: true, user_id: '61889')
    allow_any_instance_of(HubEdos::AcademicStatus).to receive(:new).and_return fake_proxy
  end

  let(:described_class_instance) { described_class.new(random_id) }

  describe '#get_feed_internal' do
    subject { described_class_instance.get_feed_internal }
    it 'provides a set of roles based on the user\'s academic status' do
      expect(subject).to be
      expect(subject.keys.count).to eq 24
      expect(subject['ugrd']).to eq true
      expect(subject['grad']).to eq false
      expect(subject['fpf']).to eq false
      expect(subject['law']).to eq false
      expect(subject['concurrent']).to eq false
      expect(subject['doctorScienceLaw']).to eq false
      expect(subject['lettersAndScience']).to eq true
      expect(subject['haasBusinessAdminMasters']).to eq false
      expect(subject['haasBusinessAdminPhD']).to eq false
      expect(subject['haasFullTimeMba']).to eq false
      expect(subject['haasEveningWeekendMba']).to eq false
      expect(subject['haasExecMba']).to eq false
      expect(subject['haasMastersFinEng']).to eq false
      expect(subject['haasMbaPublicHealth']).to eq false
      expect(subject['haasMbaJurisDoctor']).to eq false
      expect(subject['jurisSocialPolicyMasters']).to eq false
      expect(subject['jurisSocialPolicyPhC']).to eq false
      expect(subject['jurisSocialPolicyPhD']).to eq false
      expect(subject['lawJspJsd']).to eq false
      expect(subject['lawJdLlm']).to eq false
      expect(subject['lawVisiting']).to eq false
      expect(subject['ugrdUrbanStudies']).to eq false
      expect(subject['summerVisitor']).to eq false
      expect(subject['courseworkOnly']).to eq false
    end
  end

  describe '#collect_roles' do
    subject { described_class_instance.collect_roles(academic_statuses) }

    context 'when academic_statuses is nil' do
      let(:academic_statuses) { nil }
      it 'returns an empty array' do
        expect(subject).to eq []
      end
    end
    context 'when academic_statuses is an empty array' do
      let(:academic_statuses) { [] }
      it 'returns an empty array' do
        expect(subject).to eq []
      end
    end
    context 'when student has no roles' do
      let(:academic_statuses) { ['STATUS1', 'STATUS2']}
      it 'returns an empty array' do
        expect(subject).to eq []
      end
    end
  end

  describe '#extract_roles' do
    subject { described_class_instance.extract_roles(status) }

    context 'when status is nil' do
      let(:status) { nil }
      it 'returns an empty array' do
        expect(subject).to eq []
      end
    end
  end
end
