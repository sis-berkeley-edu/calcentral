module User
  module Notifications
    class Expiry
      ENF::Processor.instance.register("sis:student:messages", self)

      def self.call(message)
        ::User::Notifications::CachedFeed.expire(message.student_uid)
      end
    end
  end
end
