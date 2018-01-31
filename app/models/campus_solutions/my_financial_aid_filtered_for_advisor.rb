module CampusSolutions
  class MyFinancialAidFilteredForAdvisor < UserSpecificModel

    include ClassLogger
    include Cache::CachedFeed
    include Cache::JsonAddedCacher
    include Cache::RelatedCacheKeyTracker
    include CampusSolutions::FinaidFeatureFlagged

    attr_accessor :aid_year

    def get_feed_as_json(force_cache_write=false)
      feed = get_feed force_cache_write
      feed.to_json
    end

    def get_feed_internal
      model = CampusSolutions::MyFinancialAidData.new(@uid)
      model.aid_year = aid_year
      apply_filter model.get_feed
    end

    def apply_filter(feed)
      advisor_uid = authentication_state.original_advisor_user_id
      raise RuntimeError, "Only advisors have access to this filtered #{instance_key} FinAid feed" unless advisor_uid
      logger.debug "Advisor #{advisor_uid} viewing user #{@uid} financial aid feed where aid_year = #{aid_year}"
      {
        filteredForAdvisor: true
      }.merge(remove_confidential_information feed)
    end

    def remove_confidential_information(feed={})
      return feed unless feed[:feed] && feed[:feed][:status] && (categories = feed[:feed][:status][:categories])
      categories.each do |category|
        if category[:itemGroups]
          category[:itemGroups].each do |group|
            group.reject! { |item| has_confidential_information? item }
          end
        end
      end
      feed
    end

    def instance_key
      "#{@uid}-#{aid_year}"
    end

    def has_confidential_information?(item)
      !!(item[:title].to_s =~ /expected\sfamily\scontribution|berkeley\sparent\scontribution/i)
    end
  end
end
