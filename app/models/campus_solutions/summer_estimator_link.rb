module CampusSolutions
  class SummerEstimatorLink

    def get_feed
      get_summer_estimator_link
    end

    def get_summer_estimator_link
      link_config = { cs_link_key: 'UC_FA_SUMMR_EST_FLU' }
      link = LinkFetcher.fetch_link(link_config[:cs_link_key])
      { summerEstimator: link }
    end

  end
end
