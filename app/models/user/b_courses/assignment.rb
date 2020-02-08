module User
  module BCourses
    class Assignment
      include HtmlSanitizer

      attr_accessor :id, :name, :html_url, :description, :due_at, :course_id,
        :needs_grading_count, :points_possible

      def initialize(attrs={})
        attrs.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def due_date
        due_at&.to_date
      end

      def due_time
        due_at&.to_datetime
      end

      def sanitized_description
        sanitize_html(description)
      end
    end
  end
end
