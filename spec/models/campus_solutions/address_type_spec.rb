describe CampusSolutions::AddressType do
  let(:proxy) { CampusSolutions::AddressType.new(fake: true) }
  subject { proxy.get }
  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that properly observes the profile feature flag'
  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    expect(subject[:feed][:addressTypes]).to be
    expect(subject[:feed][:addressTypes][0][:fieldvalue]).to be
    expect(subject[:feed][:addressTypes][0][:descr]).to be
  end
end
