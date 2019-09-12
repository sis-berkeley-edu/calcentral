module User
  module Academics
    class StudentAttribute
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def as_json(options={})
        {
          term_id: term_id,
          is_cnp_exception: is_cnp_exception?,
          is_officially_registered: is_officially_registered?,
          type_code: type_code,
          type_description: type_description,
          reason_code: reason_code,
          reason_description: reason_description
        }
      end

      def is_cnp_exception?
        type_code == '+R99'
      end

      def twenty_percent_cnp_exception?
        type_code == '+R99' && reason_code == 'SF20%'
      end

      # The tuition calculated indicator is always S09 and TCALC
      def tuition_calculated?
        type_code == '+S09' && reason_code == 'TCALC'
      end

      def registered?
        type_code == '+REG'
      end

      def term_id
        start_term_id
      end

      def type_code
        data['type']['code']
      rescue NoMethodError
      end

      def type_description
        data['type']['description']
      rescue NoMethodError
      end

      def reason_code
        data['reason']['code']
      rescue NoMethodError
      end

      def reason_description
        data['reason']['description']
      rescue NoMethodError
      end

      def service_indicator_message
        data['reason']['formalDescription']
      rescue NoMethodError
      end

      def single_term
        start_term_id.present? && start_term_id == end_term_id
      end

      def start_term_id
        data['fromTerm']['id']
      rescue NoMethodError
      end

      def end_term_id
        data['toTerm']['id']
      rescue NoMethodError
      end
    end
  end
end
