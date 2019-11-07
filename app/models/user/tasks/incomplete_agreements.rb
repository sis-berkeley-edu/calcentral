module User
  module Tasks
    class IncompleteAgreements < ::User::Owned
      LINK_API_KEY='UC_CC_AGRMNT_WEBMSG'

      def as_json(options = {})
        all
      end

      def all
        @all ||= incomplete_agreements_data.map do |agreement|
          IncompleteAgreement.new(agreement)
        end
      end

      private

      def incomplete_agreements_data
        @incomplete_agreements_data ||= User::Tasks::Queries.incomplete_agreements(user.uid) || []
      end
    end
  end
end
