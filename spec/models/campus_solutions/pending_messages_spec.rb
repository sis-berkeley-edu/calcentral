describe CampusSolutions::PendingMessages do
  let(:user_id) { '12348' }
  let(:proxy) { CampusSolutions::PendingMessages.new(fake: true, user_id: user_id) }
  subject { proxy.get }
  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that properly observes the profile feature flag'
  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    expect(subject[:feed][:commMessagePendingResponse][0]).to be
  end
  it 'returns specific mock data' do
    p "subj=#{subject}"
    expect(subject[:feed][:commMessagePendingResponse][0][:emplid]).to eq '26662066'
    expect(subject[:feed][:commMessagePendingResponse][0][:descr]).to eq 'Missing Information Notice'
  end
end
