module Financials
  module LoanHistory
    class Merged < UserSpecificModel
      include MergedModel

      def user_specific_providers
        []
      end

      def globally_cached_providers
        []
      end

      def get_feed
        feed = {}
        handling_provider_exceptions(feed, user_specific_providers) { |provider| provider.new(@uid).merge feed }
        handling_provider_exceptions(feed, globally_cached_providers) { |provider| provider.new().merge feed }
        feed
      end
    end
  end
end
