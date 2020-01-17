module User
  module FinancialAid
    class AidYears
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def get_feed
        {
          aidYears: ::FinancialAid::MyAidYears.new(user.uid).get_feed.try(:[], :aidYears)
        }
      end
    end
  end
end
