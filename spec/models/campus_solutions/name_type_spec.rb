describe CampusSolutions::NameType do
  let(:proxy) { CampusSolutions::NameType.new(fake: true) }
  subject { proxy.get }
  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that properly observes the profile feature flag'
  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    expect(subject[:feed][:nameTypes]).to be
    expect(subject[:feed][:nameTypes][0][:nameTypeDescr]).to be
    expect(subject[:feed][:nameTypes][1][:nameTypeDescr]).to be
  end
end
