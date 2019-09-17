module User
  module Academics
    class StudentGroup
      def initialize(data)
        @data = data
      end

      def code
        @data['student_group_code']
      end

      def as_json(options={})
        {
          code: @data['student_group_code'],
          description: @data['student_group_description'],
          fromDate: @data['from_date']&.to_date,
        }
      end
    end
  end
end
