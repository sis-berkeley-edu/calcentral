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
    let(:careers) do
      [
        {"code"=>"GRAD", "description"=>"Graduate"},
        {"code"=>"LAW", "description"=>"Law"},
        {"code"=>"GRAD", "description"=>"Graduate"},
      ]
    end
    before do
      allow(HubEdos::MyAcademicStatus).to receive(:get_careers).and_return careers
    end
    it 'return unique career descriptions' do
      expect(subject.get_active_careers).to eq ['Graduate', 'Law']
    end
  end

end
