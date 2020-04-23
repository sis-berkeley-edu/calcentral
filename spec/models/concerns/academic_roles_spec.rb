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

  shared_examples 'a translator that handles invalid input' do
    context 'when code is nil' do
      let(:code) { nil }
      it { should be nil }
    end
    context 'when code is not mapped to any role' do
      let(:code) { 'BUNK' }
      it { should eq [] }
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

  context 'when defining group roles' do
    subject { described_class::STUDENT_GROUP_ROLES }
    it_behaves_like 'a map of academic status codes to roles'
  end

  describe '#get_academic_plan_roles' do
    subject { described_class.get_academic_plan_roles code }
    it_behaves_like 'a translator that handles invalid input'

    context 'when a match is found' do
      let(:code) { '99V06G' }
      it { should contain_exactly 'summerVisitor' }
    end
  end

  describe '#get_academic_plan_roles' do
    subject { described_class.get_academic_plan_roles(code) }
    context 'when code is nil' do
      let(:code) { nil }
      it { should be nil }
    end

    context 'when code is not mapped to any role' do
      let(:code) { '25000ABCD' }
      it { should eq [] }
    end
  end

  describe '#get_academic_program_roles' do
    subject { described_class.get_academic_program_roles(code) }

    context 'when code is nil' do
      let(:code) { nil }
      it { should be nil }
    end
    context 'when code is not mapped to any role' do
      let(:code) { 'BUNK' }
      it { should eq ['degreeSeeking'] }
    end
    context 'when a match is found' do
      let(:code) { 'UCLS' }
      it { should contain_exactly('lettersAndScience', 'degreeSeeking') }
    end
  end

  describe '#get_academic_career_roles' do
    subject { described_class.get_academic_career_roles(code) }
    it_behaves_like 'a translator that handles invalid input'

    context 'when a match is found' do
      let(:code) { 'LAW' }
      it { should contain_exactly 'law' }
    end
  end

  describe '#get_student_group_roles' do
    subject { described_class.get_student_group_roles(group_code) }
    context 'when a match is found' do
      let(:group_code) { 'LJD' }
      it { should contain_exactly 'lawJointDegree' }
    end
  end

  describe '#role_defaults' do
    subject { described_class.role_defaults }
    it 'returns all possible roles set to false' do
      expect(subject.keys.count).to eq 34
      expect(subject['concurrent']).to eq false
      expect(subject['courseworkOnly']).to eq false
      expect(subject['degreeSeeking']).to eq false
      expect(subject['doctorScienceLaw']).to eq false
      expect(subject['fpf']).to eq false
      expect(subject['grad']).to eq false
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
      expect(subject['law']).to eq false
      expect(subject['lawJdCdp']).to eq false
      expect(subject['lawJdLlm']).to eq false
      expect(subject['lawJointDegree']).to eq false
      expect(subject['lawJspJsd']).to eq false
      expect(subject['lawVisiting']).to eq false
      expect(subject['lettersAndScience']).to eq false
      expect(subject['ugrdEngineering']).to eq false
      expect(subject['ugrdEnvironmentalDesign']).to eq false
      expect(subject['ugrdHaasBusiness']).to eq false
      expect(subject['ugrdNaturalResources']).to eq false
      expect(subject['masterOfLawsLlm']).to eq false
      expect(subject['summerVisitor']).to eq false
      expect(subject['ugrd']).to eq false
      expect(subject['ugrdNonDegree']).to eq false
      expect(subject['ugrdUrbanStudies']).to eq false
    end
  end
end
