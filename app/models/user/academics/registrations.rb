module User
  module Academics
    class Registrations
      attr_reader :user

      def initialize(user)
        @user = user
      end

      def all
        @all ||= data_feed.collect do |data|
          ::User::Academics::Registration.new(data)
        end.sort_by(&:term_id)
      end

      def latest
        all.select { |reg| reg.term_id == latest_term_id }
      end

      def latest_term_id
        all.last.term_id
      end

      def term_ids
        all.map { |reg| reg.term_id }.compact.uniq
      end

      def find_by_term_id(term_id)
        all.select { |reg| reg.term_id == term_id }
      end

      def latest_academic_level_descriptions
        latest.collect {|reg| reg.preferred_level.description }
      end

      def data_feed
        @registrations ||= HubEdos::StudentApi::V2::Registrations.new(user_id: user.uid).get[:feed]['registrations'] || []
      rescue NoMethodError
        []
      end
    end
  end
end
