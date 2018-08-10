describe CampusSolutions::EthnicitySetup do
  let(:proxy) { CampusSolutions::EthnicitySetup.new(fake: true) }
  subject { proxy.get }
  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that properly observes the profile feature flag'
  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    expect(subject[:feed][:ethnictySetup]).to be
    expect(subject[:feed][:ethnictySetup][:answerMapping]).to be
  end
end
