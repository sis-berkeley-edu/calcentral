describe CampusSolutions::ResidencyMessage do
  # let(:fake_proxy) { true }
  let(:message_nbr) {'2005'}
  let(:params) { {messageNbr: message_nbr} }
  let(:proxy) { CampusSolutions::ResidencyMessage.new(fake: true, params: params) }
  subject{
    proxy.get
  }

  it_should_behave_like 'a simple proxy that returns errors'
  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    message = subject[:feed][:root][:getMessageCatDefn]
    expect(message[:messageSetNbr]).to eq "28001"
    expect(message[:messageNbr]).to eq message_nbr
    expect(message[:messageText]).to be
    expect(message[:descrlong]).to be
  end
end
