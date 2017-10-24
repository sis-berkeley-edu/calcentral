module MyClasses
  class Merged < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::FilterJsonOutput
    include MergedModel

    def self.providers
      [
        MyClasses::Canvas
      ]
    end

    def get_feed_internal
      campus = Campus.new(@uid)
      campus_courses = campus.fetch

      feed = {}
      feed[:classes] = merge_sites(feed, campus_courses[:current], campus.current_term)
      feed[:current_term] = campus.current_term.to_english
      if campus_courses[:gradingInProgress]
        feed[:gradingInProgressClasses] = merge_sites(feed, campus_courses[:gradingInProgress], campus.grading_in_progress_term)
      end
      feed
    end

    def merge_sites(feed, courses, term)
      sites = courses.dup
      handling_provider_exceptions(feed, self.class.providers) do |provider|
        provider.new(@uid).merge_sites(courses, term, sites)
      end
      sites
    end

    def filter_for_view_as(feed)
      if authentication_state.authenticated_as_advisor?
        feed[:classes].delete_if {|t| t[:emitter] == 'bCourses' || t[:role] == 'Instructor'}
      end
      feed
    end
  end
end
