describe Concerns::AcademicRoles do

  shared_examples 'a map of academic status codes to roles' do
    it 'includes plans and career matchers' do
      expect(subject.count).to_not eq 0
    end

    it 'defines role code and match string for each matcher' do
      subject.each do |matcher|
        expect(matcher).to have_key(:role_code)
        expect(matcher).to have_key(:match)
      end
    end
  end

  shared_examples 'a translator that returns the role corresponding to an academic status' do
    context 'when code is nil' do
      let(:code) { nil }
      it { should be nil }
    end
    context 'when code is not mapped' do
      let(:code) { 'BUNK' }
      it { should be nil }
    end
  end

  context 'when defining plan roles' do
    subject { described_class::ACADEMIC_PLAN_ROLES }
    it_behaves_like 'a map of academic status codes to roles'
  end

  context 'when defining program roles' do
    subject { described_class::ACADEMIC_PROGRAM_ROLES }

    it_behaves_like 'a map of academic status codes to roles'
  end

  context 'when defining career roles' do
    subject { described_class::ACADEMIC_CAREER_ROLES }
    it_behaves_like 'a map of academic status codes to roles'
  end

  describe '#get_academic_plan_role_code' do
    subject { described_class.get_academic_plan_role_code code }
    it_behaves_like 'a translator that returns the role corresponding to an academic status'

    context 'when a match is found' do
      let(:code) { '99V06G' }
      it { should eq 'summerVisitor' }
    end
  end

  describe '#get_academic_program_role_code' do
    subject { described_class.get_academic_program_role_code(code) }

    it_behaves_like 'a translator that returns the role corresponding to an academic status'

    context 'when a match is found' do
      let(:code) { 'UCLS' }
      it { should eq 'lettersAndScience' }
    end
  end

  describe '#get_academic_career_role_code' do
    subject { described_class.get_academic_career_role_code(code) }
    it_behaves_like 'a translator that returns the role corresponding to an academic status'

    context 'when a match is found' do
      let(:code) { 'LAW' }
      it { should eq 'law' }
    end
  end

  describe '#role_defaults' do
    subject { described_class.role_defaults }
    it 'returns all possible roles set to false' do
      expect(subject.keys.count).to eq (24)
      expect(subject['ugrd']).to eq false
      expect(subject['grad']).to eq false
      expect(subject['law']).to eq false
      expect(subject['concurrent']).to eq false
      expect(subject['lettersAndScience']).to eq false
      expect(subject['doctorScienceLaw']).to eq false
      expect(subject['fpf']).to eq false
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
end
