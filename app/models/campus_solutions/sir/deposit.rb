module CampusSolutions
  module Sir
    class Deposit < Proxy

      include CampusSolutions::CampusSolutionsIdRequired

      def initialize(options = {})
        super options
        @adm_appl_nbr = options[:adm_appl_nbr]
        initialize_mocks if @fake
      end

      def xml_filename
        'deposit.xml'
      end

      def url
        "#{@settings.base_url}/UC_DEPOSIT_AMT.v1/deposit/get?EMPLID=#{@campus_solutions_id}&ADM_APPL_NBR=#{@adm_appl_nbr}"
      end

    end
  end
end
