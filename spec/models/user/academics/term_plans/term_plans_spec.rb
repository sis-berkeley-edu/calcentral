describe User::Academics::TermPlans::TermPlans do
  let(:uid) { '61889' }
  let(:user) { User::Current.new(uid) }
  let(:data) do
    [
      {"term_id"=>"2198", "acad_career"=>"UGRD", "acad_career_descr"=>"Undergraduate", "acad_program"=>"UCLS", "acad_plan"=>"25000U"},
      {"term_id"=>"2192", "acad_career"=>"UGRD", "acad_career_descr"=>"Undergraduate", "acad_program"=>"UCLS", "acad_plan"=>"25000U"},
      {"term_id"=>"2195", "acad_career"=>"UGRD", "acad_career_descr"=>"Undergraduate", "acad_program"=>"UCLS", "acad_plan"=>"25000U"},
      {"term_id"=>"2202", "acad_career"=>"GRAD", "acad_career_descr"=>"Graduate", "acad_program"=>"GACAD", "acad_plan"=>"ABCDEF"},
      {"term_id"=>"2188", "acad_career"=>"UGRD", "acad_career_descr"=>"Undergraduate", "acad_program"=>"UCLS", "acad_plan"=>"25000U"},
    ]
  end
  let(:term_plans_cached) { double(get_feed: data) }
  subject { described_class.new(user) }
  let(:current_term) { double(campus_solutions_id: '2198')}
  let(:berkeley_terms) { double(current: current_term) }
  before do
    allow(Berkeley::Terms).to receive(:fetch).and_return(berkeley_terms)
    allow(User::Academics::TermPlans::TermPlansCached).to receive(:new).and_return(term_plans_cached)
  end

  describe 'all' do
    let(:result) { subject.all }
    it 'returns all term plans' do
      result.each do |term_plan|
        expect(term_plan).to be_an_instance_of User::Academics::TermPlans::TermPlan
      end
    end
    it 'returns all term plans from newest to oldest' do
      expect(result.first.term_id).to eq '2202'
      expect(result.last.term_id).to eq '2188'
    end
    context 'when no term plans present' do
      let(:data) { [] }
      it 'returns empty array' do
        expect(result).to eq([])
      end
    end
  end

  describe 'current_and_future' do
    let(:current_term) { double(campus_solutions_id: '2198')}
    it 'returns only current and future term plans' do
      result = subject.current_and_future
      expect(result.count).to eq 2
      expect(result[0].term_id).to eq '2202'
      expect(result[1].term_id).to eq '2198'
    end
    context 'when no current or future term plans present' do
      let(:current_term) { double(campus_solutions_id: '2208')}
      it 'returns empty array' do
        expect(subject.current_and_future).to eq([])
      end
    end
  end

  describe '#latest_career_code' do
    it 'returns the career code of the latest career term' do
      expect(subject.latest_career_code).to eq 'GRAD'
    end
  end
end
