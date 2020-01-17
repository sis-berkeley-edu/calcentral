module User
  module FinancialAid
    class AwardComparisonData
      attr_reader :user

      def initialize(user, aid_year, effective_date)
        @user = user
        @aid_year = aid_year
        @effective_date = effective_date
      end

      def as_json(options={})
        award_comparison_data
      end

      def award_comparison_data
        @award_comparison_data ||= CachedAwardComparisonData.new(@user.uid, @aid_year, @effective_date).get_feed
      end
    end
  end
end
