module User
  module Academics
    class Level
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def type_code
        data['type']['code']
      end

      def description
        data['level']['description']
      end
    end
  end
end
