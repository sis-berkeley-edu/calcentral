describe CampusSolutions::MyFinancialAidData do
  subject { CampusSolutions::MyFinancialAidData.from_session(state) }

  context 'mock proxy' do
    let(:state) { { 'fake' => true, 'user_id' => random_id } }
    let(:feed) { subject.get_feed }
    context 'no aid year provided' do
      it 'should return empty' do
        expect(feed).to be_empty
      end
    end
    context 'aid year provided' do
      before { subject.aid_year = '2016' }
      it 'should return feed' do
        expect(feed).to_not be_empty
      end
  end
  end
end
