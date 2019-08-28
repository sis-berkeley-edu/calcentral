module User
  module Academics
    class StatusAndHolds
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def as_json(options={})
        {
          termRegistrations: user.term_registrations.active
        }
      end
    end
  end
end
