describe MyAcademics::MyAcademicRoles do

  before do
    allow_any_instance_of(Berkeley::Term).to receive(:campus_solutions_id).and_return('2172')
    allow_any_instance_of(MyAcademics::MyTermCpp).to receive(:get_feed).and_return(term_cpp)
  end
  let(:term_cpp) do
    [
      {'term_id'=>'2158', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
      {'term_id'=>'2162', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
      {'term_id'=>'2168', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
      {'term_id'=>'2172', 'acad_career'=>'GRAD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
    ]
  end
  let(:described_class_instance) { described_class.new(random_id) }

  describe '#get_feed_internal' do
    subject { described_class_instance.get_feed_internal }
    it 'provides a set of roles based on the user\'s current academic status' do
      expect(subject).to be
      expect(subject[:current]).to be
      expect(subject[:current].keys.count).to eq 30
      expect(subject[:current]['ugrd']).to eq false
      expect(subject[:current]['grad']).to eq true
      expect(subject[:current]['fpf']).to eq false
      expect(subject[:current]['law']).to eq false
      expect(subject[:current]['concurrent']).to eq false
      expect(subject[:current]['degreeSeeking']).to eq true
      expect(subject[:current]['doctorScienceLaw']).to eq false
      expect(subject[:current]['lettersAndScience']).to eq false
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
      expect(subject[:current]['masterOfLawsLlm']).to eq false
      expect(subject[:current]['ugrdNonDegree']).to eq false
      expect(subject[:current]['ugrdEngineering']).to eq false
      expect(subject[:current]['ugrdEnvironmentalDesign']).to eq false
      expect(subject[:current]['ugrdUrbanStudies']).to eq false
      expect(subject[:current]['summerVisitor']).to eq false
      expect(subject[:current]['courseworkOnly']).to eq false
      expect(subject[:current]['lawJdCdp']).to eq false
    end
    it 'provides a set of roles based on all of the user\'s past academic data' do
      expect(subject).to be
      expect(subject[:historical]).to be
      expect(subject[:historical].keys.count).to eq 30
      expect(subject[:historical]['ugrd']).to eq true
      expect(subject[:historical]['grad']).to eq true
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
      expect(subject[:historical]['ugrdEngineering']).to eq false
      expect(subject[:historical]['ugrdEnvironmentalDesign']).to eq false
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
end
