describe CampusSolutions::MyFinancialAidData do
  subject { CampusSolutions::MyFinancialAidData.from_session(state) }

  before do
    # mock feed modification for housing
    allow(CampusSolutions::FinancialAidHousing).to receive(:append_housing) do |uid, feed|
      feed[:feed][:housing][:instruction] = 'mock instructions'
      feed
    end
  end

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
      it 'should include housing data' do
        expect(feed[:feed][:housing][:title]).to eq 'Housing'
        expect(feed[:feed][:housing][:values]).to be
        expect(feed[:feed][:housing][:link]).to be
      end
      it 'should append housing messaging and links' do
        expect(feed[:feed][:housing][:instruction]).to eq 'mock instructions'
      end
  end
  end
end
