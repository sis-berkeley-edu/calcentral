module CampusSolutions
  class TransferCredit < Proxy

    include CampusSolutionsIdRequired

    def xml_filename
      'transfer_credit.xml'
    end

    def url
      "#{@settings.base_url}/UC_SR_TRANSFER_CREDIT.v1/get?EMPLID=#{@campus_solutions_id}"
    end

  end
end
