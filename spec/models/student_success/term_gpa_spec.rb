describe StudentSuccess::TermGpa do
  let(:user_id) { '61889' }
  context 'a mock proxy' do
    before do
      allow(Settings.campus_solutions_proxy).to receive(:fake).and_return true
      allow(Settings.hub_edos_proxy).to receive(:fake).and_return true
      allow(Berkeley::Terms.fetch).to receive(:current).and_return 2142
    end
    context 'correctly parses the feed' do
      let(:subject) { StudentSuccess::TermGpa.new(user_id: user_id).merge }
      it 'returns data in an array' do
        expect(subject).to be_an Array
      end
      it 'removes terms with invalid data' do
        subject.each do |term|
          expect(term[:termId]).not_to equal(2172)
          expect(term[:career]).not_to equal('Graduate')
          expect(term[:termGpaUnits]).not_to equal (0)
        end
      end
    end
  end

  context 'get_active_careers' do
    let(:subject) { StudentSuccess::TermGpa.new(user_id: user_id) }
    before do
      allow_any_instance_of(MyAcademics::MyTermCpp).to receive(:get_feed).and_return(term_cpp)
    end
    context 'when term cpp data is present' do
      let(:term_cpp) do
        [
          {"term_id"=>"2135", "acad_career"=>"UGRD", "acad_career_descr"=>"Undergraduate", "acad_program"=>"UCLS", "acad_plan"=>"25000U"},
          {"term_id"=>"2138", "acad_career"=>"GRAD", "acad_career_descr"=>"Graduate", "acad_program"=>"GPRFL", "acad_plan"=>"70141BAJDG"},
          {"term_id"=>"2142", "acad_career"=>"GRAD", "acad_career_descr"=>"Graduate", "acad_program"=>"GPRFL", "acad_plan"=>"70141BAJDG"},
          {"term_id"=>"2145", "acad_career"=>"LAW", "acad_career_descr"=>"Law", "acad_program"=>"LPRFL", "acad_plan"=>"84501JDBAG"},
        ]
      end
      it 'return unique career descriptions' do
        expect(subject.get_active_careers).to eq ['Graduate', 'Law']
      end
    end
    context 'when term cpp data is not present' do
      let(:term_cpp) { [] }
      it 'returns empty array' do
        expect(subject.get_active_careers).to eq []
      end
    end
  end

end
