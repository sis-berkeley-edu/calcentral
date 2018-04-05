module CampusSolutions
  class EmergencyLoanLink

    def get_feed
      get_emergency_loan_link
    end

    def get_emergency_loan_link
      link_config = { cs_link_key: 'UC_CX_EMERGENCY_LOAN_FORM' }
      link = LinkFetcher.fetch_link(link_config[:cs_link_key])
      { emergencyLoan: link }
    end

  end
end
