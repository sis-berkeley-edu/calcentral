module EdoOracle
  module UserCourses
    class All < Base

      include Cache::UserCacheExpiry

      def get_all_campus_courses
        # Because this data structure is used by multiple top-level feeds, it's essential
        # that it be cached efficiently.
        self.class.fetch_from_cache @uid do
          campus_classes = {}
          merge_instructing campus_classes
          merge_enrollments campus_classes
          sort_courses campus_classes

          # Sort the hash in descending order of semester.
          campus_classes = Hash[campus_classes.sort.reverse]

          # Merge each section's schedule, location, and instructor list.
          # TODO Is this information useful for non-current terms?
          merge_detailed_section_data(campus_classes)

          campus_classes
        end
      end

      def get_enrollments_summary
        self.class.fetch_from_cache "summary-#{@uid}" do
          campus_classes = {}
          merge_enrollments campus_classes
          sort_courses campus_classes
          campus_classes = Hash[campus_classes.sort.reverse]
          remove_duplicate_sections(campus_classes)
          campus_classes
        end
      end

    end
  end
end
