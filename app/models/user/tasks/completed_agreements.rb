module User
  module Tasks
    class CompletedAgreements < ::User::Owned
      def as_json(options = {})
        all
      end

      def all
        @all ||= data.map do |agreement|
          CompletedAgreement.new(agreement)
        end
      end

      def visible
        all.select(&:visible?)
      end

      private

      def data
        @data ||= User::Tasks::Queries.completed_agreements(user.uid) || []
      end
    end
  end
end
