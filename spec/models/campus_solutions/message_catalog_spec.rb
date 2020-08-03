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
  let(:message_catalog_constant) do
    {
      max_cancel_amount: [26500, 112]
    }
  end
  before { stub_const("CampusSolutions::MessageCatalog::CATALOG", message_catalog_constant) }

  describe '.get_message' do
    let(:message_key) { :max_cancel_amount }
    subject { described_class.get_message(message_key) }
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
        expect(subject[:messageSetNbr]).to eq '26500'
        expect(subject[:messageNbr]).to eq '112'
        expect(subject[:messageText]).to eq 'message text'
        expect(subject[:msgSeverity]).to eq 'M'
        expect(subject[:descrlong]).to eq 'long message description'
      end
    end
  end

  describe '.get_message_collection' do
    let(:message_keys) { [:max_cancel_amount] }
    subject { described_class.get_message_collection(message_keys) }
    it 'returns messages hash' do
      expect(subject).to be_an_instance_of Hash
      expect(subject.keys).to eq [:max_cancel_amount]
      expect(subject[:max_cancel_amount][:messageSetNbr]).to eq '26500'
      expect(subject[:max_cancel_amount][:messageNbr]).to eq '112'
      expect(subject[:max_cancel_amount][:messageText]).to eq 'Reduce/Cancel: Max Cancelable Amount is Zero'
      expect(subject[:max_cancel_amount][:msgSeverity]).to eq 'M'
      expect(subject[:max_cancel_amount][:descrlong]).to eq 'YOU CANNOT REDUCE OR CANCEL THIS LOAN.'
    end
  end

  describe '#get' do
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
end
