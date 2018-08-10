describe CampusSolutions::Sir::Deposit do
  let(:user_id) { '12348' }
  let(:proxy) { CampusSolutions::Sir::Deposit.new(fake: true, user_id: user_id, adm_appl_nbr: '00000087') }
  subject { proxy.get }

  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    expect(subject[:feed][:depositResponse]).to be
    expect(subject[:feed][:depositResponse][:deposit][:emplid]).to be
  end

  it 'should get specific mock data' do
    expect(subject[:feed][:depositResponse][:deposit][:emplid]).to eq '24188949'
    expect(subject[:feed][:depositResponse][:deposit][:dueDt]).to eq '2015-09-01'
  end
end
