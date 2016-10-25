module MyAcademics
  class TransferCredit
    include AcademicsModule

    def merge(data)
      data[:transferCredit] = transfer_credit
    end

    def transfer_credit
      response = CampusSolutions::TransferCredit.new(user_id: @uid).get
      response = response.try(:[], :feed).try(:[], :root).try(:[], :ucTransferCredits).try(:[], :transferCredit)
      if (credit = response[:ucTransferCrseSch])
        adjusted_units = credit[:unitsAdjust].to_f
        nonadjusted_units = credit[:unitsNonAdjusted].to_f
        response[:ucTransferCrseSch][:unitsTotal] = adjusted_units + nonadjusted_units
      end
      response
    end

  end
end
