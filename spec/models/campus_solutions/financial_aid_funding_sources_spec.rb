describe CampusSolutions::FinancialAidFundingSources do
  let(:user_id) { '12345' }
  let(:proxy) { CampusSolutions::FinancialAidFundingSources.new(user_id: user_id, fake: true) }
  subject { proxy.get }
  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that properly observes the financial_aid feature flag'
  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    expect(subject[:feed][:message]).to be
    expect(subject[:feed][:awards]).to be
  end
end
