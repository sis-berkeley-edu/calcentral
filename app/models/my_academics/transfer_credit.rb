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
      response[:tcReportLink] = fetch_tc_report_link
      response
    end

    def fetch_tc_report_link
      lookup_student_id
      fetch_link('UC_CX_XFER_CREDIT_REPORT_STDNT', { :EMPLID => @campus_solutions_id })
    end

    def lookup_student_id
      if @uid
        @campus_solutions_id = CalnetCrosswalk::ByUid.new(user_id: @uid).lookup_campus_solutions_id
      end
    end

  end
end
