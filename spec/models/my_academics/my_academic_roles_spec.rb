describe MyAcademics::MyAcademicRoles do
  let(:uid) { random_id }
  subject { described_class.new(uid) }

  let(:current_user) do
    instance_double('User::Current').tap do |mock|
      allow(mock).to receive(:student_groups).and_return(student_groups)
    end
  end
  let(:student_groups) do
    instance_double('User::Academics::StudentGroups').tap do |mock|
      allow(mock).to receive(:codes).and_return(group_codes)
    end
  end
  let(:group_codes) { ['AHC', 'AIC', 'VAC', 'LJD'] }

  let(:my_term_cpp) do
    instance_double('MyAcademics::MyTermCpp').tap do |mock|
      allow(mock).to receive(:get_feed).and_return(term_cpp)
    end
  end
  let(:term_cpp) do
    [
      {'term_id'=>'2158', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
      {'term_id'=>'2162', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
      {'term_id'=>'2168', 'acad_career'=>'UGRD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
      {'term_id'=>'2172', 'acad_career'=>'GRAD', 'acad_program'=>'UCNR', 'acad_plan'=>'04606U'},
    ]
  end

  before do
    allow_any_instance_of(Berkeley::Term).to receive(:campus_solutions_id).and_return('2172')
    allow(User::Current).to receive(:new).with(uid).and_return(current_user)
    allow(MyAcademics::MyTermCpp).to receive(:new).with(uid).and_return(my_term_cpp)
  end

  describe '#get_feed_internal' do
    let(:result) { subject.get_feed_internal }
    it 'provides a set of roles based on the user\'s current academic status' do
      expect(result).to be
      expect(result[:current]).to be
      expect(result[:current].keys.count).to eq 32
      expect(result[:current]['ugrd']).to eq false
      expect(result[:current]['grad']).to eq true
      expect(result[:current]['fpf']).to eq false
      expect(result[:current]['law']).to eq false
      expect(result[:current]['concurrent']).to eq false
      expect(result[:current]['degreeSeeking']).to eq true
      expect(result[:current]['doctorScienceLaw']).to eq false
      expect(result[:current]['lettersAndScience']).to eq false
      expect(result[:current]['haasBusinessAdminMasters']).to eq false
      expect(result[:current]['haasBusinessAdminPhD']).to eq false
      expect(result[:current]['haasFullTimeMba']).to eq false
      expect(result[:current]['haasEveningWeekendMba']).to eq false
      expect(result[:current]['haasExecMba']).to eq false
      expect(result[:current]['haasMastersFinEng']).to eq false
      expect(result[:current]['haasMbaPublicHealth']).to eq false
      expect(result[:current]['haasMbaJurisDoctor']).to eq false
      expect(result[:current]['jurisSocialPolicyMasters']).to eq false
      expect(result[:current]['jurisSocialPolicyPhC']).to eq false
      expect(result[:current]['jurisSocialPolicyPhD']).to eq false
      expect(result[:current]['lawJspJsd']).to eq false
      expect(result[:current]['lawJdLlm']).to eq false
      expect(result[:current]['lawJointDegree']).to eq true
      expect(result[:current]['lawVisiting']).to eq false
      expect(result[:current]['masterOfLawsLlm']).to eq false
      expect(result[:current]['ugrdNonDegree']).to eq false
      expect(result[:current]['ugrdEngineering']).to eq false
      expect(result[:current]['ugrdEnvironmentalDesign']).to eq false
      expect(result[:current]['ugrdHaasBusiness']).to eq false
      expect(result[:current]['ugrdUrbanStudies']).to eq false
      expect(result[:current]['summerVisitor']).to eq false
      expect(result[:current]['courseworkOnly']).to eq false
      expect(result[:current]['lawJdCdp']).to eq false
    end
    it 'provides a set of roles based on all of the user\'s past academic data' do
      expect(result).to be
      expect(result[:historical]).to be
      expect(result[:historical].keys.count).to eq 32
      expect(result[:historical]['ugrd']).to eq true
      expect(result[:historical]['grad']).to eq true
      expect(result[:historical]['fpf']).to eq false
      expect(result[:historical]['law']).to eq false
      expect(result[:historical]['concurrent']).to eq false
      expect(result[:historical]['degreeSeeking']).to eq true
      expect(result[:historical]['doctorScienceLaw']).to eq false
      expect(result[:historical]['lettersAndScience']).to eq false
      expect(result[:historical]['haasBusinessAdminMasters']).to eq false
      expect(result[:historical]['haasBusinessAdminPhD']).to eq false
      expect(result[:historical]['haasFullTimeMba']).to eq false
      expect(result[:historical]['haasEveningWeekendMba']).to eq false
      expect(result[:historical]['haasExecMba']).to eq false
      expect(result[:historical]['haasMastersFinEng']).to eq false
      expect(result[:historical]['haasMbaPublicHealth']).to eq false
      expect(result[:historical]['haasMbaJurisDoctor']).to eq false
      expect(result[:historical]['jurisSocialPolicyMasters']).to eq false
      expect(result[:historical]['jurisSocialPolicyPhC']).to eq false
      expect(result[:historical]['jurisSocialPolicyPhD']).to eq false
      expect(result[:historical]['lawJspJsd']).to eq false
      expect(result[:historical]['lawJdLlm']).to eq false
      expect(result[:historical]['lawJointDegree']).to eq false
      expect(result[:historical]['lawVisiting']).to eq false
      expect(result[:historical]['ugrdNonDegree']).to eq false
      expect(result[:historical]['ugrdUrbanStudies']).to eq false
      expect(result[:historical]['ugrdEngineering']).to eq false
      expect(result[:historical]['ugrdEnvironmentalDesign']).to eq false
      expect(result[:historical]['ugrdHaasBusiness']).to eq false
      expect(result[:historical]['summerVisitor']).to eq false
      expect(result[:historical]['courseworkOnly']).to eq false
      expect(result[:historical]['lawJdCdp']).to eq false
    end

    context 'when student has only summer visitor plans under non-degree programs' do
      let(:term_cpp) do
        [
          {'term_id'=>'2125', 'acad_career'=>'UGRD', 'acad_program'=>'UNODG', 'acad_plan'=>'99000U'},
          {'term_id'=>'2135', 'acad_career'=>'UGRD', 'acad_program'=>'UNODG', 'acad_plan'=>'99000U'},
        ]
      end
      it 'sets roles approrpriately' do
        expect(result[:historical]['summerVisitor']).to eq true
        expect(result[:historical]['degreeSeeking']).to eq false
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
        expect(result[:historical]['summerVisitor']).to eq true
        expect(result[:historical]['degreeSeeking']).to eq true
      end
    end
    context 'when student has only non-degree programs' do
      let(:term_cpp) do
        [
          {'term_id'=>'2168', 'acad_career'=>'UCBX', 'acad_program'=>'XCCRT', 'acad_plan'=>'30XCECCENX'},
          {'term_id'=>'2172', 'acad_career'=>'UCBX', 'acad_program'=>'XCCRT', 'acad_plan'=>'30XCECCENX'},
        ]
      end
      it 'sets roles appropriately' do
        expect(result[:historical]['summerVisitor']).to eq false
        expect(result[:historical]['degreeSeeking']).to eq false
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
        expect(result[:historical]['summerVisitor']).to eq false
        expect(result[:historical]['degreeSeeking']).to eq true
      end
    end
  end

  describe '#term_cpp' do
    it 'memoizes the term cpp data' do
      expect(my_term_cpp).to receive(:get_feed).once.and_return(term_cpp)
      result1 = subject.term_cpp
      result2 = subject.term_cpp
      expect(result1.count).to eq 4
      expect(result2.count).to eq 4
      expect(result1.first['term_id']).to eq '2158'
      expect(result2.first['term_id']).to eq '2158'
    end
  end

  describe '#student_group_codes' do
    it 'memoizes the student group codes' do
      expect(student_groups).to receive(:codes).once.and_return(group_codes)
      result1 = subject.student_group_codes
      result2 = subject.student_group_codes
      expect(result1.first).to eq 'AHC'
      expect(result2.first).to eq 'AHC'
    end
  end
end
