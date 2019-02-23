module CalGrant
  class Acknowledgement < UserSpecificModel
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      {
        acknowledgements: HashConverter.camelize(activity_guides)
      }
    end

    private

    def activity_guides
      @activity_guides ||= Queries.get_activity_guides(@uid).map do |data|
        data['link'] = acknowledgement_link(data['id'])
        data['status'] = if data['status'] == 'IP'
                           'Incomplete'
                         elsif data['status'] == 'CP'
                           'Complete'
                         end
        data
      end
    end

    def acknowledgement_link(activity_guide_id)
      LinkFetcher.fetch_link('UC_CX_ACTIVITY_GUIDE_CA_ENROLL', {
        'INSTANCE_ID' => activity_guide_id
      })
    end
  end
end
