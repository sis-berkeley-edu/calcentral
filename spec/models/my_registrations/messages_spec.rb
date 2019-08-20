describe MyRegistrations::Messages do
  let(:enrollment_verification_messages) do
    (100..106).collect do |num|
      {
        messageSetNbr: '32500',
        messageNbr: num.to_s,
        messageText: "message text #{num}",
        msgSeverity: 'M',
        descrlong: "long description #{num}"
      }
    end
  end
  let(:enrollment_verification_messages_feed) { {feed: {root: {getMessageCatDefn: enrollment_verification_messages}}} }
  let(:enrollment_verification_messages_model) { double(:enrollment_verification_messages, get: enrollment_verification_messages_feed) }
  before do
    allow(CampusSolutions::EnrollmentVerificationMessages).to receive(:new).and_return(enrollment_verification_messages_model)
  end

  describe '.regstatus_messages' do
    let(:result) { described_class.regstatus_messages }
    it 'returns registration status message set' do
      expect(described_class.regstatus_messages[:notOfficiallyRegistered]).to eq 'long description 100'
      expect(described_class.regstatus_messages[:cnpNotificationUndergrad]).to eq 'long description 101'
      expect(described_class.regstatus_messages[:feesUnpaidGrad]).to eq 'long description 102'
      expect(described_class.regstatus_messages[:cnpWarningUndergrad]).to eq 'long description 103'
      expect(described_class.regstatus_messages[:cnpWarningGrad]).to eq 'long description 104'
      expect(described_class.regstatus_messages[:notEnrolledUndergrad]).to eq 'long description 105'
      expect(described_class.regstatus_messages[:notEnrolledGrad]).to eq 'long description 106'
    end
  end
end
