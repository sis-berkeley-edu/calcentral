module MyAcademics
  module Law
    class Awards < UserSpecificModel
      include Cache::CachedFeed
      include Cache::JsonifiedFeed
      include Cache::UserCacheExpiry

      def awards
        @awards ||= HashConverter.camelize(Query.awards_for_user(@uid))
      end
    end
  end
end
