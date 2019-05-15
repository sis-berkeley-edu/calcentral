module MyAcademics
  module Law
    class TranscriptNotes < UserSpecificModel
      include Cache::CachedFeed
      include Cache::JsonifiedFeed
      include Cache::UserCacheExpiry

      def notes
        @notes ||= HashConverter.camelize(Query.transcript_notes_for_user(@uid))
      end
    end
  end
end
