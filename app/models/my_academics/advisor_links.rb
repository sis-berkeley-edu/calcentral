module MyAcademics
  class AdvisorLinks
    include AcademicsModule
    include ClassLogger
    include LinkFetcher

    def merge(data)
      data[:advisorLinks] = links
    end

    def links
      campus_solutions_id = get_campus_solutions_id(@uid)
      tcReportLink = fetch_link('UC_CX_XFER_CREDIT_REPORT_ADVSR', { :EMPLID => campus_solutions_id })
      updatePlanUrl = fetch_link('UC_CX_PLANNER_ADV_STDNT', {:EMPLID => campus_solutions_id})
      {
        tcReportLink: tcReportLink,
        updatePlanUrl: updatePlanUrl
      }
    end
  end
end
