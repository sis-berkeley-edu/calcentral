describe CampusSolutions::MessageCatalog do
  shared_examples 'a proxy that gets data' do
    let(:message_set_nbr) {'26500'}
    let(:message_nbr) {'112'}
    let(:fake_flag) { true }
    let(:params) { {fake: fake_flag, message_set_nbr: message_set_nbr, message_nbr: message_nbr} }
    let(:proxy) { CampusSolutions::MessageCatalog.new(params) }
    subject {
      proxy.get
    }

    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      message = subject[:feed][:root][:getMessageCatDefn]
      expect(message[:messageSetNbr]).to eq "26500"
      expect(message[:messageNbr]).to eq message_nbr
      expect(message[:messageText]).to be
      expect(message[:descrlong]).to be
    end
  end

  context 'mock proxy' do
    let(:fake_proxy) { true }
    it_should_behave_like 'a proxy that gets data'
  end

  context 'real proxy', testext: true do
    let(:fake_proxy) { false }
    it_should_behave_like 'a proxy that gets data'
  end
end
