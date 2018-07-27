describe CampusSolutions::FinancialAidCompareAwardsList do
  let(:user_id) { '12345' }
  let(:proxy) { CampusSolutions::FinancialAidCompareAwardsList.new(user_id: user_id, fake: true) }
  subject { proxy.get }
  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that properly observes the finaid award compare feature flag'
  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    expect(subject[:feed][:awardParms]).to be
  end
end
