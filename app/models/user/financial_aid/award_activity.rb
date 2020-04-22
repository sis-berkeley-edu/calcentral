module User
  module FinancialAid
    class AwardActivity
      attr_reader :user

      def initialize(user, aid_year)
        @user = user
        @aid_year = aid_year
      end

      def as_json(options={})
        award_activity_dates.map{|date| date['activity_date'].to_date}
      end

      def most_recent_activity_date_by_year
        award_activity_dates.first.try(:[], 'activity_date')
      end

      def award_activity_dates
        @award_activity_dates ||= CachedAwardActivity.new(@user.uid, @aid_year).get_feed
      end
    end
  end
end
