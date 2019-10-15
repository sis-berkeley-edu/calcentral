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

      def preferred_for_career_code?(career_code)
        if career_code == 'LAW'
          end_of_term?
        else
          beginning_of_term?
        end
      end

      def end_of_term?
        type_code == 'EOT'
      end

      def beginning_of_term?
        type_code == 'BOT'
      end
    end
  end
end
