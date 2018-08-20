module FinancialAid
  class MyFinancialAidSummary < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include CampusSolutions::FinaidFeatureFlagged
    include Concerns::NewAdmits
    include LinkFetcher
    include User::Identifiers

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
          shoppingSheetLink: shopping_sheet_link(aid_year_id)
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

    def shopping_sheet_link(aid_year)
      return nil unless undergrad_new_admit?(admit_status) && admit_year_match?(aid_year)
      fetch_link('UC_CX_FA_SHOPPING_SHEET', {AID_YEAR: aid_year, ACAD_CAREER: 'UGRD', INSTITUTION: INSTITUTION, SFA_SS_GROUP: 'CCUGRD'})
    end

    def admit_year_match?(aid_year)
      undergrad_new_admit_status = admit_status.try(:[], :sirStatuses).try(:find) {|status| status[:isUndergraduate]}
      admit_term = undergrad_new_admit_status.try(:[], :newAdmitAttributes).try(:[], :term).try(:[], :term)
      admit_year = Berkeley::TermCodes.from_edo_id(admit_term).try(:[], :term_yr)
      admit_year == aid_year
    end

    def admit_status
      CampusSolutions::Sir::SirStatuses.new(@uid).get_feed
    end

    def aid_years
      @aid_years ||= CampusSolutions::MyAidYears.new(@uid).get_feed.try(:[], :feed).try(:[], :finaidSummary).try(:[], :finaidYears)
    end
  end
end
