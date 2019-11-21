module FinancialAid
  class FinancialResources
    include Cache::CachedFeed
    include LinkFetcher

    def get_feed
      financial_resources_links
    end

    def financial_resources
      @financial_resources ||= EdoOracle::FinancialAid::Queries.get_financial_resources_links()
    end

    def financial_resources_links
      Hash.new.tap do |links|
        financial_resources.each do |cs_link|
          links[cs_link['url_id']] = fetch_link(cs_link['url_id'], link_params)
        end
      end
    end

    def link_params
      {
        INSTITUTION: 'UCB01'
      }
    end
  end
end
