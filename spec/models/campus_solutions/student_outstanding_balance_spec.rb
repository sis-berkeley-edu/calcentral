describe CampusSolutions::StudentOutstandingBalance do
  let(:user_id) { '61889' }
  let(:proxy) { CampusSolutions::StudentOutstandingBalance.new(user_id: user_id, fake: true) }
  subject { proxy.get }
  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that properly observes the student success feature flag'
  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    expect(subject[:feed][:ucSfAccountData]).to be
    expect(subject[:feed][:ucSfAccountData][:outstandingBalance]).to be
  end
end
