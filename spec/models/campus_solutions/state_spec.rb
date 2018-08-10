describe CampusSolutions::State do
  let(:proxy) { CampusSolutions::State.new(fake: true, country: 'USA') }
  subject { proxy.get }
  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that properly observes the profile feature flag'
  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    expect(subject[:feed][:states]).to be
    expect(subject[:feed][:states][0][:state]).to eq 'MT'
  end
end
