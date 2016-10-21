module MailingLists
  class OutgoingMessage

    def initialize(member, mailing_list, opts={})
      @member = member
      @mailing_list = mailing_list
      @opts = opts
    end

    def send_message
      # TODO set parameters for outgoing message
      Mailgun::SendMessage.new.post(
        from: '',
        to: '',
        subject: ''
      )
    end

  end
end
