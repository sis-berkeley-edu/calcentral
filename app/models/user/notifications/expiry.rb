module User
  module Notifications
    class Expiry < ::ENF::Handler
      ENF::Processor.instance.register("sis:student:messages", self)

      def self.call(message)
        self.new(message).expire
      end

      def expire
        uids.each do |uid|
          ::User::Notifications::CachedFeed.expire(uid)
        end
      end
    end
  end
end
