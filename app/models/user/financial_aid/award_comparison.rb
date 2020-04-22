module User
  module FinancialAid
    class AwardComparison
      include AllowDelegateViewAs
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def as_json(options={})
        {
          aidYears: aid_years,
          message: CampusSolutions::MessageCatalog.get_message(:financial_aid_award_comparison_card_info).try(:[], :descrlong),
        }
      end

      def aid_years
        User::FinancialAid::AidYears.new(user).get_feed.try(:[], :aidYears).map do |year|
          AidYear.new(user, year);
        end
      end
    end
  end
end
