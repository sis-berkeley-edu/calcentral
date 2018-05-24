describe MyAcademics::MyAcademicRoles do

  describe '#get_historical_roles' do
    subject { described_class.new(uid).get_historical_roles }
    let(:uid) { 61889 }

    it 'includes a key for every possible role' do
      expect(subject).to be
      expect(subject.keys.count).to eq 27
    end
    it 'sets role flag to true for every relevant career, program, and plan the student has ever had' do
      expect(subject['concurrent']).to eq true
      expect(subject['courseworkOnly']).to eq true
      expect(subject['degreeSeeking']).to eq true
      expect(subject['doctorScienceLaw']).to eq true
      expect(subject['fpf']).to eq true
      expect(subject['grad']).to eq true
      expect(subject['haasBusinessAdminMasters']).to eq true
      expect(subject['haasBusinessAdminPhD']).to eq true
      expect(subject['haasFullTimeMba']).to eq true
      expect(subject['haasEveningWeekendMba']).to eq true
      expect(subject['haasExecMba']).to eq true
      expect(subject['haasMastersFinEng']).to eq true
      expect(subject['haasMbaPublicHealth']).to eq true
      expect(subject['haasMbaJurisDoctor']).to eq true
      expect(subject['jurisSocialPolicyMasters']).to eq true
      expect(subject['jurisSocialPolicyPhC']).to eq false
      expect(subject['jurisSocialPolicyPhD']).to eq true
      expect(subject['law']).to eq true
      expect(subject['lawJdCdp']).to eq true
      expect(subject['lawJdLlm']).to eq true
      expect(subject['lawJspJsd']).to eq true
      expect(subject['lawVisiting']).to eq true
      expect(subject['lettersAndScience']).to eq true
      expect(subject['summerVisitor']).to eq true
      expect(subject['ugrd']).to eq true
      expect(subject['ugrdUrbanStudies']).to eq true
    end
  end

  context 'using stubbed proxy' do
    before do
      fake_proxy = HubEdos::AcademicStatus.new(fake: true, user_id: '61889')
      allow_any_instance_of(HubEdos::AcademicStatus).to receive(:new).and_return fake_proxy
      allow_any_instance_of(MyAcademics::MyTermCpp).to receive(:get_feed).and_return(term_cpp)
    end
    let(:term_cpp) do
      [
        {'term_id'=>'2158', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
        {'term_id'=>'2162', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
        {'term_id'=>'2168', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
        {'term_id'=>'2172', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
      ]
    end
    let(:described_class_instance) { described_class.new(random_id) }

    describe '#get_feed_internal' do
      subject { described_class_instance.get_feed_internal }
      it 'provides a set of roles based on the user\'s current academic status' do
        expect(subject).to be
        expect(subject[:current]).to be
        expect(subject[:current].keys.count).to eq 27
        expect(subject[:current]['ugrd']).to eq true
        expect(subject[:current]['grad']).to eq false
        expect(subject[:current]['fpf']).to eq false
        expect(subject[:current]['law']).to eq false
        expect(subject[:current]['concurrent']).to eq true
        expect(subject[:current]['degreeSeeking']).to eq false
        expect(subject[:current]['doctorScienceLaw']).to eq false
        expect(subject[:current]['lettersAndScience']).to eq true
        expect(subject[:current]['haasBusinessAdminMasters']).to eq false
        expect(subject[:current]['haasBusinessAdminPhD']).to eq false
        expect(subject[:current]['haasFullTimeMba']).to eq false
        expect(subject[:current]['haasEveningWeekendMba']).to eq false
        expect(subject[:current]['haasExecMba']).to eq false
        expect(subject[:current]['haasMastersFinEng']).to eq false
        expect(subject[:current]['haasMbaPublicHealth']).to eq false
        expect(subject[:current]['haasMbaJurisDoctor']).to eq false
        expect(subject[:current]['jurisSocialPolicyMasters']).to eq false
        expect(subject[:current]['jurisSocialPolicyPhC']).to eq false
        expect(subject[:current]['jurisSocialPolicyPhD']).to eq false
        expect(subject[:current]['lawJspJsd']).to eq false
        expect(subject[:current]['lawJdLlm']).to eq false
        expect(subject[:current]['lawVisiting']).to eq false
        expect(subject[:current]['ugrdNonDegree']).to eq false
        expect(subject[:current]['ugrdUrbanStudies']).to eq false
        expect(subject[:current]['summerVisitor']).to eq false
        expect(subject[:current]['courseworkOnly']).to eq false
        expect(subject[:current]['lawJdCdp']).to eq false
      end
      it 'provides a set of roles based on all of the user\'s past academic data' do
        expect(subject).to be
        expect(subject[:historical]).to be
        expect(subject[:historical].keys.count).to eq 27
        expect(subject[:historical]['ugrd']).to eq true
        expect(subject[:historical]['grad']).to eq false
        expect(subject[:historical]['fpf']).to eq false
        expect(subject[:historical]['law']).to eq false
        expect(subject[:historical]['concurrent']).to eq false
        expect(subject[:historical]['degreeSeeking']).to eq true
        expect(subject[:historical]['doctorScienceLaw']).to eq false
        expect(subject[:historical]['lettersAndScience']).to eq false
        expect(subject[:historical]['haasBusinessAdminMasters']).to eq false
        expect(subject[:historical]['haasBusinessAdminPhD']).to eq false
        expect(subject[:historical]['haasFullTimeMba']).to eq false
        expect(subject[:historical]['haasEveningWeekendMba']).to eq false
        expect(subject[:historical]['haasExecMba']).to eq false
        expect(subject[:historical]['haasMastersFinEng']).to eq false
        expect(subject[:historical]['haasMbaPublicHealth']).to eq false
        expect(subject[:historical]['haasMbaJurisDoctor']).to eq false
        expect(subject[:historical]['jurisSocialPolicyMasters']).to eq false
        expect(subject[:historical]['jurisSocialPolicyPhC']).to eq false
        expect(subject[:historical]['jurisSocialPolicyPhD']).to eq false
        expect(subject[:historical]['lawJspJsd']).to eq false
        expect(subject[:historical]['lawJdLlm']).to eq false
        expect(subject[:historical]['lawVisiting']).to eq false
        expect(subject[:historical]['ugrdNonDegree']).to eq false
        expect(subject[:historical]['ugrdUrbanStudies']).to eq false
        expect(subject[:historical]['summerVisitor']).to eq false
        expect(subject[:historical]['courseworkOnly']).to eq false
        expect(subject[:historical]['lawJdCdp']).to eq false
      end

      context 'when student has only summer visitor plans under non-degree programs' do
        let(:term_cpp) do
          [
            {'term_id'=>'2125', 'acad_career'=>'UGRD', 'acad_program'=>'UNODG', 'acad_plan'=>'99000U'},
            {'term_id'=>'2135', 'acad_career'=>'UGRD', 'acad_program'=>'UNODG', 'acad_plan'=>'99000U'},
          ]
        end
        it 'sets roles approrpriately' do
          expect(subject[:historical]['summerVisitor']).to eq true
          expect(subject[:historical]['degreeSeeking']).to eq false
        end
      end
      context 'when student has summer visitor plans under degree-seeking programs, plus non-degree programs' do
        let(:term_cpp) do
          [
            {'term_id'=>'2155', 'acad_career'=>'GRAD', 'acad_program'=>'UCLS', 'acad_plan'=>'99000G'},
            {'term_id'=>'2165', 'acad_career'=>'GRAD', 'acad_program'=>'UCLS', 'acad_plan'=>'99000G'},
            {'term_id'=>'2168', 'acad_career'=>'UCBX', 'acad_program'=>'XCCRT', 'acad_plan'=>'30XCECCENX'},
            {'term_id'=>'2172', 'acad_career'=>'UCBX', 'acad_program'=>'XCCRT', 'acad_plan'=>'30XCECCENX'},
            {'term_id'=>'2175', 'acad_career'=>'GRAD', 'acad_program'=>'UCLS', 'acad_plan'=>'99000G'},
          ]
        end
        it 'sets roles approrpriately' do
          expect(subject[:historical]['summerVisitor']).to eq true
          expect(subject[:historical]['degreeSeeking']).to eq true
        end
      end
      context 'when student has only non-degree programs' do
        let(:term_cpp) do
          [
            {'term_id'=>'2168', 'acad_career'=>'UCBX', 'acad_program'=>'XCCRT', 'acad_plan'=>'30XCECCENX'},
            {'term_id'=>'2172', 'acad_career'=>'UCBX', 'acad_program'=>'XCCRT', 'acad_plan'=>'30XCECCENX'},
          ]
        end
        it 'sets roles approrpriately' do
          expect(subject[:historical]['summerVisitor']).to eq false
          expect(subject[:historical]['degreeSeeking']).to eq false
        end
      end
      context 'when student has only degree-seeking programs' do
        let(:term_cpp) do
          [
            {'term_id'=>'2162', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
            {'term_id'=>'2168', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
            {'term_id'=>'2172', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
          ]
        end
        it 'sets roles approrpriately' do
          expect(subject[:historical]['summerVisitor']).to eq false
          expect(subject[:historical]['degreeSeeking']).to eq true
        end
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
end
