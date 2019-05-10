module CampusSolutions
  module Billing
    class Activity < Proxy

      include BillingFeatureFlagged
      include CampusSolutionsIdRequired

      def initialize(options = {})
        super options
        initialize_mocks if @fake
      end

      def xml_filename
        'billing_details.xml'
      end

      def build_feed(response)
        return {} unless response && (billing = response['UC_SF_ACTIVITY'])
        normalize_term_names billing
        billing
      end

      def normalize_term_names(billing)
        billing['SUMMARY']['CURRENT_TERM'] = Berkeley::TermCodes.normalized_english billing['SUMMARY']['CURRENT_TERM']
        billing['ACTIVITY'].each do |activity_item|
          activity_item['ITEM_TERM_DESCRIPTION'] = Berkeley::TermCodes.normalized_english activity_item['ITEM_TERM_DESCRIPTION']
        end
      end

      def url
        "#{@settings.base_url}/UC_SF_BILLING_DETAILS.v1/Get?EMPLID=#{@campus_solutions_id}"
      end

    end
  end
end
