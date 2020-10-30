module User
  module Academics
    class Term
      TERM_CODES = {
        "B" => "Spring",
        "C" => "Summer",
        "D" => "Fall"
      }

      attr_reader :term_id

      def initialize(term_id)
        @term_id = term_id
      end

      def now
        Settings.terms.fake_now || Cache::CacheableDateTime.new(DateTime.now)
      end

      def semester_name
        TERM_CODES.fetch(code) { "" }
      end

      delegate :to_english, :code, to: :berkeley_term

      def summer?
        berkeley_term.is_summer
      end

      def past?
        now > berkeley_term&.end
      end

      def active?
        !past?
      end

      def past_add_drop?
        berkeley_term.end_drop_add ? now > berkeley_term.end_drop_add : false
      end

      # Undergrad students are dropped on the first day of instruction.
      def past_classes_start?
        now > berkeley_term.classes_start
      end

      # All term registration statuses are hidden the day after the term ends.
      def past_end_of_instruction?
        now > berkeley_term.end
      end

      # Financial Aid disbursement is used in CNP notification.
      # This is defined as 9 days before the start of instruction.
      def past_financial_disbursement?
        now >= (berkeley_term.classes_start - 9)
      end

      def berkeley_term
        @berkeley_term ||= Berkeley::Terms.find_by_campus_solutions_id(term_id) || NullTerm.new(term_id)
      end
    end
  end
end
