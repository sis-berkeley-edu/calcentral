describe Berkeley::AcademicRoles do
  let(:type) { nil }

  shared_examples 'a map of academic status codes to roles' do
    it 'includes plans and career matchers' do
      expect(subject.count).to_not eq 0
    end

    it 'defines type code and match string for each matcher' do
      subject.each do |matcher|
        expect(matcher).to have_key(:role_code)
        expect(matcher).to have_key(:match)
      end
    end

    it 'includes types array' do
      subject.each do |matcher|
        expect(matcher).to have_key(:types)
        expect(matcher[:types]).to be_an Array
        matcher[:types].each do |type|
          expect(type).to be_a Symbol
        end
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

  context 'when defining career roles' do
    subject { described_class::ACADEMIC_CAREER_ROLES }

    it_behaves_like 'a map of academic status codes to roles'
  end

  describe '#get_academic_plan_role_code' do
    subject { described_class.get_academic_plan_role_code(code, type) }

    it_behaves_like 'a translator that returns the role corresponding to an academic status'

    context 'when a match is found' do
      let(:code) { '99V06G' }
      it { should eq 'summerVisitor' }
    end

    context 'when looking for a type-specific role' do
      let(:type) { :enrollment }

      context 'when no type match is found for this code' do
        let(:code) { '701F1MFEG' }
        it { should be nil }
      end

      context 'when a match is found' do
        let(:code) { '25000FPFU' }
        it { should eq 'fpf' }
      end

      context 'when type is not mapped' do
        let(:type) { :garbage }
        let(:code) { '25000FPFU' }
        it { should be nil }
      end
    end
  end

  describe '#get_academic_career_role_code' do
    subject { described_class.get_academic_career_role_code(code, type) }

    it_behaves_like 'a translator that returns the role corresponding to an academic status'

    context 'when a match is found' do
      let(:code) { 'LAW' }
      it { should eq 'law' }
    end

    context 'when looking for a type-specific role' do
      let(:type) { :enrollment }

      context 'when a match is found' do
        let(:code) { 'UCBX' }
        it { should eq 'concurrent' }
      end

      context 'when type is not mapped' do
        let(:type) { :garbage }
        let(:code) { 'UCBX' }
        it { should be nil }
      end
    end
  end

  describe '#role_defaults' do
    subject { described_class.role_defaults }

    it 'returns all possible roles set to false' do
      expect(subject.keys.count).to eq (13)
      expect(subject['ugrd']).to eq false
      expect(subject['grad']).to eq false
      expect(subject['fpf']).to eq false
      expect(subject['law']).to eq false
      expect(subject['concurrent']).to eq false
      expect(subject['haasFullTimeMba']).to eq false
      expect(subject['haasEveningWeekendMba']).to eq false
      expect(subject['haasExecMba']).to eq false
      expect(subject['haasMastersFinEng']).to eq false
      expect(subject['haasMbaPublicHealth']).to eq false
      expect(subject['haasMbaJurisDoctor']).to eq false
      expect(subject['ugrdUrbanStudies']).to eq false
      expect(subject['summerVisitor']).to eq false
    end
  end
  end
