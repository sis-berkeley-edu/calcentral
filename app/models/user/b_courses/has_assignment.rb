module User
  module BCourses
    module HasAssignment
      extend ActiveSupport::Concern

      included do
        attr_reader :assignment

        delegate :name, to: :assignment
        delegate :id, to: :assignment
        delegate :due_date, to: :assignment
        delegate :due_time, to: :assignment
        delegate :course_id, to: :assignment
        delegate :sanitized_description, to: :assignment

        def assignment=(data)
          @assignment = Assignment.new(data)
        end

        def has_assignment?
          assignment.present?
        end

        def assignment_url
          assignment&.html_url
        end
      end
    end
  end
end
