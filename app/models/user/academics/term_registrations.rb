module User
  module Academics
    class TermRegistrations
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def as_json(options={})
        return all
      end

      def all
        user.registrations.term_ids.map do |term_id|
          ::User::Academics::TermRegistration.new(user, User::Academics::Term.new(term_id))
        end
      end

      def active
        all.select(&:active?)
      end

      def find_by_term_id(term_id)
        all.find { |attr| attr.term_id == term_id }
      end
    end
  end
end
