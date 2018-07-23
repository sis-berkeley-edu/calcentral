module Finaid
  class MyHousing < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include CampusSolutions::FinaidFeatureFlagged
    include Concerns::DatesAndTimes
    include Concerns::NewAdmits

    attr_accessor :aid_year

    INSTRUCTIONAL_MESSAGE_NUMBERS = {
      generic: '117',
      fall_pathways: '116',
      spring_pathways: '118'
    }

    def get_feed_internal
      return {} unless is_feature_enabled
      @feed = EdoOracle::Queries.get_housing(@uid, my_aid_year)
      {
        housing: {
          terms: HashConverter.downcase_and_camelize(@feed),
          instruction: instruction,
          pathwayMessage: pathway_message,
          links: links,
          isFallPathway: first_year_pathway_fall_admit?(admit_status)
        }
      }
    end

    def instance_key
      "#{@uid}-#{my_aid_year}"
    end

    private

    def admit_status
      @admit_status ||= CampusSolutions::Sir::SirStatuses.new(@uid).get_feed
    end

    def instruction
      return get_message :fall_pathways if first_year_pathway_fall_admit? admit_status
      get_message :generic if undergrad_new_admit? admit_status
    end

    def pathway_message
      get_message :spring_pathways if first_year_pathway_spring_admit? admit_status
    end

    def links
      {
        updateHousing: housing_update_link,
        pathwayFinaid: pathway_finaid_link
      }
    end

    def housing_update_link
      if first_year_pathway_fall_admit? admit_status
        LinkFetcher.fetch_link('UC_CX_FA_STDNT_HOUSING_TYPE_PW', link_params)
      elsif continuing_undergrad? && can_update_housing?
        LinkFetcher.fetch_link('UC_CX_FA_STDNT_HOUSING_TYPE', link_params)
      end
    end

    def pathway_finaid_link
      LinkFetcher.fetch_link('UC_ADMT_FYPATH_FA_SPG') if first_year_pathway_spring_admit? admit_status
    end

    def link_params
      {
        AID_YEAR: my_aid_year,
        INSTITUTION: 'UCB01'
      }
    end

    def get_message(type)
      CampusSolutions::MessageCatalog.get_message_catalog_definition('26500', INSTRUCTIONAL_MESSAGE_NUMBERS[type]).try(:[], :descrlong)
    end

    def continuing_undergrad?
      is_undergrad = User::AggregatedAttributes.new(@uid).get_feed[:roles][:undergrad]
      is_continuing = !MyAcademics::MyAcademicRoles.new(@uid).get_feed[:current]['ugrdNonDegree']
      is_undergrad && is_continuing
    end

    def can_update_housing?
      max_term = @feed.try(:last)
      if (housing_period_end_date = max_term.try(:[], 'housing_end_date'))
        (Settings.terms.fake_now || DateTime.now) < cast_utc_to_pacific(housing_period_end_date)
      end
    end

    def my_aid_year
      @my_aid_year ||= (@options[:aid_year] || CampusSolutions::MyAidYears.new(@uid).default_aid_year).to_i.to_s
    end
  end
end
