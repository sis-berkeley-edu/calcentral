module MailingLists
  class IncomingMessage

    include ClassLogger

    def initialize(opts={})
      @opts = opts
      @sender_address = Mail::Address.new @opts[:sender]
      @recipient_address = Mail::Address.new @opts[:recipient]
    end

    def dispatch
      if !@sender_address.address || !@recipient_address.address
        logger.error "Could not dispatch mailing list message with bad properties: #{@opts}"
        return false
      end

      if !(mailing_list = find_mailing_list)
        bounce_nonexistent
      elsif !(member = find_member mailing_list)
        bounce_not_member
      elsif !member.can_send
        bounce_unauthorized_to_send
      else
        send_message(member, mailing_list)
      end
    end

    private

    def find_mailing_list
      if @recipient_address
        MailingLists::SiteMailingList.find_by list_name: @recipient_address.local
      end
    end

    def find_member(mailing_list)
      if @sender_address
        mailing_list.members.find_by email_address: @sender_address.address
      end
    end

    def bounce_nonexistent
      logger.warn "Bouncing message from #{@sender_address} to nonexistent mailing list #{@recipient_address}:\n#{@opts}"
      bounce <<-REASON
        The following message could not be delivered because the mailing list #{@recipient_address.address} was not found in
        our system. Please check the spelling, including underscores and dashes, against the list name that appears in
        your bCourses site.
      REASON
    end

    def bounce_not_member
      logger.warn "Bouncing message from non-member #{@sender_address} to mailing list #{@recipient_address}:\n#{@opts}"
      bounce <<-REASON
        The following message could not be delivered because the mailing list #{@recipient_address.address} did not recognize
        the email address #{@sender_address.address}. This could be because you are attempting to send from an email address
        other than your campus email.
      REASON
    end

    def bounce_unauthorized_to_send
      logger.warn "Bouncing message from read-only member #{@sender_address} to mailing list #{@recipient_address}:\n#{@opts}"
      bounce <<-REASON
        The following message could not be delivered because the email address #{@sender_address.address} is not authorized to
        send messages to the list #{@recipient_address.address}.
      REASON
    end

    def bounce(reason)
      message_text = "#{reason.squish}\n\n-------------\nFrom: #{@opts[:from]}\nTo: #{@opts[:to]}\nSubject: #{@opts[:subject]}\n#{@opts[:body][:plain]}"
      response = Mailgun::SendMessage.new.post(
        from: 'bCourses Mailing Lists <no-reply@bcourses-mail.berkeley.edu>',
        to: @opts[:sender],
        subject: 'Undeliverable mail',
        text: message_text
      )
      confirm_sending response
    end

    def send_message(member, mailing_list)
      response = MailingLists::OutgoingMessage.new(mailing_list, member, @opts).send_message
      confirm_sending response
    end

    def confirm_sending(response)
      response && response[:response] && response[:response][:sending]
    end
  end
end
