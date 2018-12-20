module CampusSolutions
  module PnpCalculator
    class CalculatorValues < UserSpecificModel
      include Cache::CachedFeed
      include Cache::UserCacheExpiry
      include Cache::RelatedCacheKeyTracker
      include User::Identifiers

      def get_feed_internal
        values
      end

      def campus_solutions_id
        @campus_solutions_id ||= lookup_campus_solutions_id(@uid)
      end

      def values
        @edo_values ||= {}.tap do |values|
          edo_response = EdoOracle::Queries.get_pnp_calculator_values campus_solutions_id
          values.merge!(HashConverter.camelize(edo_response)) if edo_response.present?
        end
      end
    end
  end
end
