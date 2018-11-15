module FinancialAid
  class MyTitle4 < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include CampusSolutions::FinaidFeatureFlagged

    def get_feed_internal
      return {} unless is_feature_enabled
      {
        title4: title4
      }
    end

    private

    def title4
      title4 = EdoOracle::FinancialAid::Queries.get_title4(@uid)
      return {} unless title4

      aid_years = FinancialAid::MyAidYears.new(@uid).get_feed.try(:[], :aidYears)

      {
        hasFinaid: !!aid_years.count,
        approved: ActiveRecord::Type::Boolean.new.type_cast_from_database(title4['approved']),
        responseDescr: title4['response_descr'],
        longTitle: title4['main_header'],
        longMessage: title4['main_body'],
        dynamicHeader: title4['dynamic_header'],
        dynamicBody: title4['dynamic_body'],
        dynamicLabel: title4['dynamic_label'],
        contactText: title4['contact_text']
      }
    end
  end
end
