module MyCommittees
  class Merged < UserSpecificModel

    include Cache::CachedFeed
    include MergedModel

    def self.providers
      [
        MyCommittees::StudentCommittees,
        MyCommittees::FacultyCommittees
      ]
    end

    def get_feed_internal
      feed = {}
      handling_provider_exceptions(feed, self.class.providers) do |provider|
        provider.new(@uid).merge feed
      end
      feed
    end

    def photo_data_or_file(person_id)
      photo_feed = Cal1card::Photo.new(person_id).get_feed
      if photo_feed[:photo]
        {
          size: photo_feed[:length],
          data: photo_feed[:photo]
        }
      end
    end

  end
end
