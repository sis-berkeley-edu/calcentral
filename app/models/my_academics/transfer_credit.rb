module MyAcademics
  class TransferCredit
    include AcademicsModule
    include ClassLogger

    def merge(data)
      data[:transferCredit] = transfer_credit
    end

    def transfer_credit
      response = CampusSolutions::TransferCredit.new(user_id: @uid).get
      response = response.try(:[], :feed).try(:[], :root).try(:[], :ucTransferCredits).try(:[], :transferCredit)
      if (credit = response.try(:[], :ucTransferCrseSch))
        transfer_credit_adjustment = credit[:tcAdjust].to_f
        adjusted_units = credit[:unitsAdjusted].to_f
        response[:ucTransferCrseSch][:unitsTotal] = transfer_credit_adjustment + adjusted_units
      end
      response
    end

  end
end
