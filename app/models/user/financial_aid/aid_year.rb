module User
  module FinancialAid
    class AidYear
      attr_reader :user

      def initialize(user, data)
        @user = user
        @data = data
      end

      def as_json(options={})
        {
          id: @data[:id],
          name: @data[:name],
          defaultAidYear: @data[:defaultAidYear],
          availableSemesters: @data[:availableSemesters],
          activityDates: activity_dates,
          currentComparisonData: current_comparison_data,
        }
      end


      def current_comparison_data
        if recent_activity_date = activity_dates.most_recent_activity_date_by_year
          User::FinancialAid::AwardComparisonData.new(user, year, recent_activity_date)
        end
      end

      def activity_dates
        @activity_dates ||= User::FinancialAid::AwardActivity.new(user, year)
      end

      def today
        @today ||= Time.zone.today.in_time_zone.to_date
      end

      def year
        @data[:id]
      end
    end
  end
end
