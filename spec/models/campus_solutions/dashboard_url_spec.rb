describe CampusSolutions::DashboardUrl do

  let(:proxy) { CampusSolutions::DashboardUrl.new(fake: true) }
  subject { proxy.get }

  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    expect(subject[:feed][:url]).to be
  end

  it 'should properly camelize the fields' do
    expect(subject[:feed][:url]).to eq('https://bcs-web-dev-03.is.berkeley.edu:8443/psc/bcsdev/EMPLOYEE/HRMS/c/CCI_COMMUNICATION_CENTER_SS.CCI_COMM_CENTER_FL.GBL')
  end

end
