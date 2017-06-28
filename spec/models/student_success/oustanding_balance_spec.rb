describe StudentSuccess::OutstandingBalance do

  context 'a mock proxy' do
    before do
      allow(Settings.campus_solutions_proxy).to receive(:fake).and_return true
    end
    it 'correctly parses the feed' do
      result = StudentSuccess::OutstandingBalance.new(user_id: 61889).merge
      expect(result).to eq 153.0
    end
  end

end
