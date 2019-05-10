module CampusSolutions
  module Billing
    class Links < GlobalCachedProxy

      include LinkFetcher

      def get
        {
          statusCode: 200,
          feed: {
            links: HashConverter.camelize(transform_link_settings)
          }
        }
      end

      def campus_solutions_link_settings
        [
          { feed_key: :student_billing, cs_link_key: 'UC_CX_FA_STU_BILL' },
          { feed_key: :delinquent_accounts, cs_link_key: 'UC_CX_FA_DEL_ACC' },
          { feed_key: :making_payments, cs_link_key: 'UC_CX_FA_PAY_OPTS' }
        ]
      end

      def transform_link_settings
        cs_links = {}

        campus_solutions_link_settings.each do |setting|
          link = fetch_link(setting[:cs_link_key])
          cs_links[setting[:feed_key]] = link
        end

        cs_links
      end

    end
  end
end
