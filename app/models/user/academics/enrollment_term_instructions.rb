module User
  module Academics
    class EnrollmentTermInstructions
      attr_reader :user
      attr_reader :term_id

      def initialize(user)
        @user = user
      end

      def all
        @all ||= term_ids.collect do |term_id|
          ::User::Academics::EnrollmentTermInstruction.new(user, term_id)
        end
      end

      def find_by_term_id(term_id)
        all.select do |term_instruction|
          term_instruction.term_id == term_id
        end.first
      end

      def as_json(options={})
        all.map(&:as_json)
      end

      private

      def term_ids
        @term_ids ||= user.enrollment_terms.all.collect(&:term_id).uniq
      end
    end
  end
end
