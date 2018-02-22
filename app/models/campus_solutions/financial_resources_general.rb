module CampusSolutions
  class FinancialResourcesGeneral

    def get_feed
      get_general_cs_links
    end

    def get_general_cs_links
      link_config = { cs_link_key: 'UC_CX_EMERGENCY_LOAN_FORM' }
      link = LinkFetcher.fetch_link(link_config[:cs_link_key])
      { emergencyLoan: link }
    end

  end
end
