module CampusSolutions
  class FinancialResourcesParameterized < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry

    def initialize(options = {})
      super options
      @aid_year = options.try(:[], :aid_year)
    end

    def get_feed_internal
      get_summer_estimator_link
    end

    def get_summer_estimator_link
      return {} if @aid_year.nil?
      link_config = { cs_link_key: 'UC_FA_SUMMR_EST_FLU', cs_link_params: { :AID_YEAR => @aid_year } }
      link = LinkFetcher.fetch_link(link_config[:cs_link_key], link_config[:cs_link_params])
      { summerEstimator: link }
    end

  end
end
