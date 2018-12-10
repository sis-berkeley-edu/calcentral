module FinancialAid
  class MyFinancialAidSummary < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include CampusSolutions::FinaidFeatureFlagged
    include LinkFetcher

    INSTITUTION = 'UCB01'

    def get_feed_internal
      return {} unless is_feature_enabled
      {
        financialAidSummary: {
          aidYears: aid_years,
          aid: aid,
          links: links
        }
      }
    end

    private

    def aid
      aid = {}
      aid_years.try(:each) do |aid_year|
        aid_year_id = aid_year[:id]
        financial_aid_summary = EdoOracle::FinancialAid::Queries.get_financial_aid_summary(@uid, aid_year_id)
        aid[aid_year_id.to_s] = {
          totalCostOfAttendance: format_currency(financial_aid_summary.try(:[], 'uc_cost_attendance')),
          totalGiftAidAndWaivers: format_currency(financial_aid_summary.try(:[], 'uc_gift_aid_waiver')),
          totalNetCost: format_currency(financial_aid_summary.try(:[], 'uc_net_cost')),
          totalFundingOffered: format_currency(financial_aid_summary.try(:[], 'uc_funding_offered')),
          giftAidAndOutsideResources: format_currency(financial_aid_summary.try(:[], 'uc_gift_aid_out')),
          grantsAndScholarships: format_currency(financial_aid_summary.try(:[], 'uc_grants_schol')),
          waiversAndOtherFunding: format_currency(financial_aid_summary.try(:[], 'uc_waivers_oth')),
          feeWaivers: format_currency(financial_aid_summary.try(:[], 'uc_fee_waivers')),
          loansAndWorkStudy: format_currency(financial_aid_summary.try(:[], 'uc_loans_wrk_study')),
          loans: format_currency(financial_aid_summary.try(:[], 'uc_loans')),
          workStudy: format_currency(financial_aid_summary.try(:[], 'uc_work_study')),
          shoppingSheetLink: shopping_sheet_link(aid_year_id, financial_aid_summary)
        }
      end
      aid
    end

    def links
      {
        financialAidWebsite: fetch_link('UC_CX_FA_UCB_FA_WEBSITE'),
        calStudentCentral: fetch_link('UC_CX_CAL_STUDENT_CENTRAL')
      }
    end

    def format_currency(amount)
      (amount || 0).to_f.round(2)
    end

    def shopping_sheet_link(aid_year, financial_aid_summary)
      group = financial_aid_summary.try(:[], 'sfa_ss_group')
      return nil unless group.present?
      fetch_link('UC_CX_FA_SHOPPING_SHEET', {EMPLID: financial_aid_summary.try(:[], 'student_id'), AID_YEAR: aid_year, ACAD_CAREER: 'UGRD', INSTITUTION: INSTITUTION, SFA_SS_GROUP: group})
    end

    def aid_years
      @aid_years ||= FinancialAid::MyAidYears.new(@uid).get_feed.try(:[], :aidYears)
    end
  end
end
