describe CampusSolutions::MessageCatalog do

  let(:message_set_nbr) { '26500' }
  let(:message_nbr) { '112' }
  let(:mocked_response) do
    {
      statusCode: status_code,
      feed: feed
    }
  end
  let(:status_code) { 200 }
  let(:feed) { {root: root} }
  let(:root) do
    {
      getMessageCatDefn: {
        messageSetNbr: message_set_nbr,
        messageNbr: message_nbr,
        messageText: 'message text',
        msgSeverity: 'M',
        descrlong: 'long message description'
      }
    }
  end

  context '.get_message_catalog_definition' do
    subject { described_class.get_message_catalog_definition(message_set_nbr, message_nbr) }
    before { allow_any_instance_of(described_class).to receive(:get).and_return(mocked_response) }

    context 'when failed response' do
      let(:status_code) { 500 }
      it { should be_nil }
    end
    context 'when message catalog definition not present' do
      let(:root) { {} }
      it { should be_nil }
    end
    context 'when message catalog definition is present' do
      it 'returns definition' do
        expect(subject).to have_key(:messageSetNbr)
        expect(subject).to have_key(:messageNbr)
        expect(subject).to have_key(:messageText)
        expect(subject).to have_key(:descrlong)
      end
    end
  end

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
