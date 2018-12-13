module FinancialAid
  class MyAidYears < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include CampusSolutions::FinaidFeatureFlagged

    def get_feed_internal
      return {} unless is_feature_enabled

      {
        aidYears: aid_years
      }
    end

    def default_aid_year
      return nil unless is_feature_enabled

      feed = self.get_feed

      default_aid_year = feed[:aidYears].select do |year|
        !!year[:defaultAidYear]
      end

      default_aid_year[0].try(:[], :id)
    end

    private

    def aid_years
      EdoOracle::FinancialAid::Queries.get_aid_years(@uid).map do |year|
        aid_year = {
          id: year['aid_year'],
          name: year['aid_year_descr'],
          defaultAidYear: ActiveRecord::Type::Boolean.new.type_cast_from_database(year['default_aid_year']),
          availableSemesters: []
        }

        #convert string to boolean and then build the availableSemesters value
        aid_year[:availableSemesters] << 'Fall' if ActiveRecord::Type::Boolean.new.type_cast_from_database(year['aid_received_fall'])
        aid_year[:availableSemesters] << 'Spring' if ActiveRecord::Type::Boolean.new.type_cast_from_database(year['aid_received_spring'])
        aid_year[:availableSemesters] << 'Summer' if ActiveRecord::Type::Boolean.new.type_cast_from_database(year['aid_received_summer'])
        aid_year
      end
    end
  end
end
