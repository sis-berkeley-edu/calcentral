module User
  module Academics
    class Hold
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def calgrant?
        type_code == 'F06'
      end

      def type_description
        data['type']['description']
      rescue NoMethodError
      end

      def reason_description
        data['reason']['description']
      rescue NoMethodError
      end

      def formal_desscription
        data['reason']['formalDescription']
      end

      def type_code
        data['type']['code']
      rescue NoMethodError
      end

      def term_id
        data['fromTerm']['id']
      rescue NoMethodError
      end
    end
  end
end
