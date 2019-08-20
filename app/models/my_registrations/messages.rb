module MyRegistrations
  module Messages
    def self.regstatus_messages
      {
        notOfficiallyRegistered: find_message_by_number(100),
        cnpNotificationUndergrad: find_message_by_number(101),
        feesUnpaidGrad: find_message_by_number(102),
        cnpWarningUndergrad: find_message_by_number(103),
        cnpWarningGrad: find_message_by_number(104),
        notEnrolledUndergrad: find_message_by_number(105),
        notEnrolledGrad: find_message_by_number(106)
      }
    end

    def self.registration_messages
      @@reg_messages ||= Proc.new do
        messages = CampusSolutions::EnrollmentVerificationMessages.new().get
        messages.try(:[], :feed).try(:[], :root).try(:[], :getMessageCatDefn) || []
      end.call
    end

    def self.find_message_by_number(message_nbr)
      registration_messages.find do |message|
        message.try(:[], :messageNbr).to_i == message_nbr
      end.try(:[], :descrlong)
    end
  end
end
