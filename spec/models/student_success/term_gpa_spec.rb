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

  let(:current_and_future_term_plans) do
    [
      double(academic_career_description: 'Graduate'),
      double(academic_career_description: 'Law'),
    ]
  end
  let(:term_plans) { double(current_and_future: current_and_future_term_plans) }

  context 'get_active_careers' do
    let(:subject) { StudentSuccess::TermGpa.new(user_id: user_id) }
    before do
      allow(User::Academics::TermPlans::TermPlans).to receive(:new).and_return(term_plans)
    end
    context 'when current and future term plans are present' do
      let(:current_and_future_term_plans) do
        [
          double(academic_career_description: 'Graduate'),
          double(academic_career_description: 'Law'),
        ]
      end
      it 'return unique career descriptions' do
        expect(subject.get_active_careers).to eq ['Graduate', 'Law']
      end
    end
    context 'when term cpp data is not present' do
      let(:current_and_future_term_plans) { [] }
      it 'returns empty array' do
        expect(subject.get_active_careers).to eq []
      end
    end
  end

end
