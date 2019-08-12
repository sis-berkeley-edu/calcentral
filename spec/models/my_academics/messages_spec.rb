describe MyAcademics::Messages do
  let(:uid) { random_id }
  subject { MyAcademics::Messages.new(uid) }
  describe '#merge' do
    let(:messages_hash) do
      {
        :waitlisted_units_warning => {
          messageSetNbr: '28000',
          messageNbr: '216',
          messageText: 'Waitlist Warning Message',
          msgSeverity: 'W',
          descrlong: 'long description'
        }
      }
    end
    before { allow(subject).to receive(:get_messages).and_return(messages_hash) }
    it 'merges messages with feed' do
      feed = {}
      subject.merge(feed)
      expect(feed[:messages].keys).to eq [:waitlisted_units_warning]
      expect(feed[:messages][:waitlisted_units_warning][:descrlong]).to eq 'long description'
    end
  end
end
