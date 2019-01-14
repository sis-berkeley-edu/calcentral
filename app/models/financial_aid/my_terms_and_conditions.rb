module FinancialAid
  class MyTermsAndConditions < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include CampusSolutions::FinaidFeatureFlagged

    attr_accessor :aid_year

    def get_feed_internal
      return {} unless is_feature_enabled
      {
        termsAndConditions: terms_and_conditions
      }
    end

    def instance_key
      "#{@uid}-#{my_aid_year}"
    end

    private

    def terms_and_conditions
      terms_and_conditions = EdoOracle::FinancialAid::Queries.get_terms_and_conditions(@uid, my_aid_year)
      return nil unless terms_and_conditions

      {
        aidYear: terms_and_conditions['aid_year'],
        approved: ActiveRecord::Type::Boolean.new.type_cast_from_database(terms_and_conditions['approved']),
        responseDescr: terms_and_conditions['response_descr'],
        mainHeader: terms_and_conditions['main_header'],
        mainBody: terms_and_conditions['main_body'],
        dynamicHeader: terms_and_conditions['dynamic_header'],
        dynamicBody: terms_and_conditions['dynamic_body']
      }
    end

    def my_aid_year
      @my_aid_year ||= (@options[:aid_year] || FinancialAid::MyAidYears.new(@uid).default_aid_year).to_i.to_s
    end
  end
end
