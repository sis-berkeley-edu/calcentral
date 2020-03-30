module User
  module BCourses
    class Event
      include HasAssignment

      attr_accessor :user
      attr_accessor :data
      attr_accessor :title
      attr_accessor :type

      def initialize(attrs={})
        attrs.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def no_grading_count?
        assignment.needs_grading_count.nil?
      end

      def course
        user.b_courses.courses.find_by_id(course_id)
      end

      delegate :course_id, to: :assignment
      delegate :course_code, to: :course

      def as_json(options={})
        {
          actionUrl: assignment_url,
          actionText: 'View in bCourses',
          displayCategory: 'bCourses',
          source: 'bCourses',
          id: id,
          type: type,
          name: name,
          dueDate: due_time.in_time_zone.to_date,
          dueTime: due_time.in_time_zone.to_datetime,
          courseCode: course_code,
          sourceUrl: assignment_url,
          status: 'inprogress',
          title: name,
          description: sanitized_description,
        }
      end
    end
  end
end
