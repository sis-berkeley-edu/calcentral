describe CampusSolutions::Translate do
  let(:proxy) { CampusSolutions::Translate.new(fake: true, field_name: 'PHONE_TYPE') }
  subject { proxy.get }

  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that properly observes the profile feature flag'
  it_behaves_like 'a proxy that got data successfully'

  it 'returns data with the expected structure' do
    expect(subject[:feed][:xlatvalues]).to be
    expect(subject[:feed][:xlatvalues][:values][0][:fieldvalue]).to be
    expect(subject[:feed][:xlatvalues][:values][0][:xlatlongname]).to be
  end

  it 'returns specific mock data' do
    expect(subject[:feed][:xlatvalues][:values][0][:fieldvalue]).to eq 'CELL'
    expect(subject[:feed][:xlatvalues][:values][0][:xlatlongname]).to eq 'Mobile'
  end
end
