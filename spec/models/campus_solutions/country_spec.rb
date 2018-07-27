describe CampusSolutions::Country do
  let(:proxy) { CampusSolutions::Country.new(fake: true) }
  subject { proxy.get }
  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that properly observes the profile feature flag'
  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    expect(subject[:feed][:countries]).to be
    expect(subject[:feed][:countries][0][:country]).to be
    expect(subject[:feed][:countries][0][:descr]).to be
    expect(subject[:feed][:countries][0][:country2char]).to be
  end
end
