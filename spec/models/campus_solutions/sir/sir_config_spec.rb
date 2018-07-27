describe CampusSolutions::Sir::SirConfig do
  let(:proxy) { CampusSolutions::Sir::SirConfig.new(fake: true) }
  subject { proxy.get }

  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that got data successfully'

  it 'returns data with the expected structure' do
    expect(subject[:feed][:sirConfig]).to be
    expect(subject[:feed][:sirConfig][:sirForms][0][:descrProgram]).to be
  end
  it 'gets specific mock data' do
    expect(subject[:feed][:sirConfig][:sirForms][0][:descrProgram]).to eq 'Grad Div Academic Prg'
    expect(subject[:feed][:sirConfig][:sirForms][0][:chklstItemCd]).to eq 'AGS001'
  end
end
