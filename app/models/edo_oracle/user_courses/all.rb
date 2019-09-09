module EdoOracle
  module UserCourses
    class All
      extend Cache::Cacheable
      include Cache::UserCacheExpiry

      def self.expire(id = nil)
        super(id)
        super("summary-#{id}")
      end

      def initialize(options)
        @uid = options[:user_id]
      end

      def all_campus_courses
        self.class.fetch_from_cache @uid do
          base_courses = EdoOracle::UserCourses::Base.new(user_id: @uid).get_all_campus_courses
          merge_enrollment_grading base_courses
          base_courses
        end
      end

      def enrollments_summary
        self.class.fetch_from_cache "summary-#{@uid}" do
          enrollments_summary = EdoOracle::UserCourses::Base.new(user_id: @uid).get_enrollments_summary
          merge_enrollment_grading enrollments_summary
          enrollments_summary
        end
      end

      def merge_enrollment_grading(courses)
        grading_table = get_grading_table
        courses.keys.each do |term_key|
          courses[term_key].each do |course|
            course[:sections].each do |section|
              term_id = course[:term_id]
              class_nbr = section[:ccn]
              section_grading = grading_table.try(:[], term_id).try(:[], class_nbr)
              if section_grading
                section[:units] = section_grading['units_taken']
                section[:grading] = get_section_grading(section, section_grading)
              end
            end
          end
        end
        courses
      end

      def get_grading_table
        terms = Berkeley::Summer16EnrollmentTerms.non_legacy_terms
        grading = EdoOracle::Queries.get_enrollment_grading(@uid, terms)
        grading_section_table = {}
        grading.each do |section|
          term_id = section['term_id']
          class_section_id = section['class_section_id']
          grading_section_table[term_id] ||= {}
          grading_section_table[term_id][class_section_id] = section
        end
        grading_section_table
      end

      def get_section_grading(section, db_row)
        grade = db_row['grade'].try(:strip)
        grade_points = db_row['grade_points']
        grade_points_adjusted = adjusted_grade_points(db_row['grade_points'], db_row['include_in_gpa'])
        grading_basis = section[:is_primary_section] ? db_row['grading_basis'] : nil
        grading_lapse_deadline = db_row['grading_lapse_deadline'].try(:strftime, '%m/%d/%y')
        grading_lapse_deadline_display = db_row['grading_lapse_deadline_display'] == 'Y'
        {
          grade: grade,
          gradingBasis: grading_basis,
          gradePoints: grade_points,
          gradePointsAdjusted: grade_points_adjusted,
          gradingLapseDeadline: grading_lapse_deadline,
          gradingLapseDeadlineDisplay: grading_lapse_deadline_display,
          includeInGpa: db_row['include_in_gpa'],
        }
      end

      def adjusted_grade_points(grade_points, include_in_gpa)
        if include_in_gpa.present? && include_in_gpa == 'N'
          return BigDecimal.new("0.0")
        else
          return grade_points
        end
      end

    end
  end
end
