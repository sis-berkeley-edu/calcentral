describe StudentSuccess::TermGpa do

  context 'a mock proxy' do
    before do
      allow(Settings.campus_solutions_proxy).to receive(:fake).and_return true
      allow(Settings.hub_edos_proxy).to receive(:fake).and_return true
      allow(Berkeley::Terms.fetch).to receive(:current).and_return 2142
    end
    context 'correctly parses the feed' do
      let(:subject) { StudentSuccess::TermGpa.new(user_id: 61889).merge }
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

end
