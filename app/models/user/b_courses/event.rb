module User
  module BCourses
    class Event
      include ActiveModel::Model
      include HasAssignment

      attr_accessor :data
      attr_accessor :title

      def initialize(attrs={})
        attrs.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def no_grading_count?
        assignment.needs_grading_count.nil?
      end

      def as_json(options={})
        {
          title: title,
          link_url: assignment_url,
          source_url: assignment_url
        }
      end
    end
  end
end
