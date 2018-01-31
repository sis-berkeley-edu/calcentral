describe CampusSolutions::MyFinancialAidFilteredForAdvisor do

  subject { CampusSolutions::MyFinancialAidFilteredForAdvisor.from_session(state) }

  context 'mock proxy' do
    let(:state) { { 'fake' => true, 'user_id' => random_id } }

    context 'no advisor session' do
      it 'should deny access' do
        expect{
          subject.get_feed
        }.to raise_exception /Only advisors have access/
      end
    end
    context 'advisor session' do
      let(:state) { { 'fake' => true, 'user_id' => random_id, SessionKey.original_advisor_user_id => random_id } }
      let(:feed) { subject.get_feed }
      let(:json) { feed.to_json }

      context 'no aid year provided' do
        it 'should indicate feed as filtered for advisor' do
          expect(feed[:filteredForAdvisor]).to be true
        end
        it 'should return an empty feed' do
          expect(subject.get_feed[:feed]).not_to be
        end
      end
      context 'aid year provided' do
        before { subject.aid_year = '2016' }
        it 'should indicate feed as filtered for advisor' do
          expect(feed[:filteredForAdvisor]).to be true
        end
        it 'includes expected items' do
          expect(json).to include 'SHIP Health Insurance'
          expect(json).to include 'Academic Career'
          expect(json).to include 'Estimated Cost of Attendance'
          expect(json).to include 'Dependency Status'
          expect(json).to include 'Family Members in College'
        end
        it 'should filter out \'Expected Family Contribution\'' do
          expect(json).to_not include 'Expected Family Contribution'
        end
        it 'should filter out \'Berkeley Parent Contribution\'' do
          expect(json).to_not include 'Berkeley Parent Contribution'
        end
      end
    end
  end
end
