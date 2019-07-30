module User
  module Finances
    module CacheExpiry
      def self.expire(uid=nil)
        CampusSolutions::Billing::MyActivity.expire(uid)
        Transactions.expire(uid)
        CachedPayments.expire(uid)
      end
    end
  end
end
