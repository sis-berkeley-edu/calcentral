module MailingLists
  class IncomingMessage

    def initialize(opts)
      @opts = opts
    end

    def dispatch
      # TODO Check sender's list permissions and forward or bounce.
      true
    end

  end
end
