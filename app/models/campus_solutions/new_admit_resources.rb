module CampusSolutions
  class NewAdmitResources < UserSpecificModel

    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::RelatedCacheKeyTracker
    include LinkFetcher
    include User::Identifiers

    SECTION_LINK_IDS = {
      map: {
        status: 'UC_ADMT_MAP_STATUS',
      },
      finAid: {
        finAidAwards: nil,
        fasoFaq: 'UC_ADMT_FA_FAQ',
        summerFinAid: 'UC_ADMT_SUM_FINAID'
      },
      admissions: {
        admissionsConditionsFreshman: 'UC_ADMT_COND_FRESH',
        admissionsConditionsTransfer: 'UC_ADMT_COND_TRANS',
        ugrdUpdateForm: 'UC_ADMT_UGRD_UPDATE',
        deferral: 'UC_ADMT_DEFER',
        withdrawBeforeMatric: 'UC_ADMT_WITHDR',
        withdrawAfterMatric: 'UC_CX_ADWITHDRL_ADD'
      },
      firstYearPathways: {
        pathwaysInfo: 'UC_ADMT_FYPATH',
        selectionForm: 'UC_ADMT_FYP_SELECT',
        pathwaysFinAid: 'UC_ADMT_FYPATH_FA_SPG'
      },
      general: {
        admissionsFaq: 'UC_ADMT_ADMSSNS_FAQ',
        calStudentCentral: 'UC_ADMT_CAL_STDNT_CNTRL',
        contactUgrdAdmissions: 'UC_ADMT_CNTCT_UGRD_ADMSSNS',
        datesDeadlines: 'UC_ADMT_GOLDEN_BEAR_DATES',
        gettingStarted: 'UC_ADMT_GETTING_STARTED'

      }
    }

    def get_feed_internal
      return { visible: false } unless attributes.try(:[], :visible)
      {
        visible: attributes.try(:[], :visible),
        links: get_links,
        admissionsEvaluator: get_admissions_evaluator
      }
    end

    def get_admissions_evaluator
      evaluator = { name: nil, email: nil }
      cs_id = lookup_campus_solutions_id
      application_number = attributes.try(:[], :applicationNbr)
      if cs_id && application_number
        evaluator_data = EdoOracle::Queries.get_new_admit_evaluator(cs_id, application_number)
        evaluator[:name] = evaluator_data.try(:[], 'evaluator_name')
        evaluator[:email] = evaluator_data.try(:[], 'evaluator_email')
      end
      evaluator
    end

    def get_links
      {
        map: links[:map],
        finAid: parse_fin_aid_links(links[:finAid]),
        admissions: parse_admissions_links(links[:admissions]),
        firstYearPathways: parse_first_year_pathways_links(links[:firstYearPathways]),
        general: links[:general]
      }
    end

    def parse_fin_aid_links(fin_aid_links)
      fin_aid_links[:finAidAwards] = {
         url: calcentral_financial_aid_link,
         linkDescription: 'View your estimated cost of attendance and financial aid awards.',
         showNewWindow: false,
         name: 'Your Financial Aid & Scholarships Awards',
         title: 'Your Financial Aid & Scholarships Awards'
       }
      fin_aid_links
    end

    def parse_admissions_links(admissions_links)
      roles = attributes.try(:[], :roles)
      admissions_links.try(:delete_if) do |link_key, link_value|
        (link_key == :admissionsConditionsFreshman && !roles.try(:[], :firstYearFreshman)) ||
        (link_key == :admissionsConditionsTransfer && !roles.try(:[], :transfer)) ||
        (link_key == :withdrawAfterMatric && roles.try(:[], :preMatriculated)) ||
        (link_key == :withdrawBeforeMatric && !roles.try(:[], :preMatriculated))
      end
    end

    def parse_first_year_pathways_links(pathways_links)
      return {} unless attributes.try(:[], :roles).try(:[], :firstYearPathway)
      if non_spring_admit(attributes.try(:[], :admitTerm))
        non_spring_pathways_fin_aid = {
          url: calcentral_financial_aid_link,
          linkDescription: pathways_links.try(:[], :pathwaysFinAid).try(:[], :linkDescription),
          showNewWindow: false,
          name: pathways_links.try(:[], :pathwaysFinAid).try(:[], :name),
          title: pathways_links.try(:[], :pathwaysFinAid).try(:[], :title)
        }
        pathways_links[:pathwaysFinAid] = non_spring_pathways_fin_aid
      end
      pathways_links
    end

    def calcentral_financial_aid_link
      latest_aid_year.present? ? '/finances/finaid/' + latest_aid_year.to_s : '/finances'
    end

    def latest_aid_year
      @aid_year ||= get_latest_aid_year
    end

    def get_latest_aid_year
      aid_years = []
      aid_years_feed = FinancialAid::MyAidYears.new(@uid).get_feed
      aid_years_feed.try(:[], :aidYears).try(:each) do |aid_year_obj|
        aid_years.push(aid_year_obj.try(:[], :id).try(:to_i))
      end
      aid_years.max
    end

    def links
      @link_config ||= {}.tap do |link_config|
        SECTION_LINK_IDS.each do |section, link_collection|
          link_config[section] = get_section_links link_collection
        end
      end
    end

    def get_section_links(link_collection)
      {}.tap do |section_links|
        link_collection.each do |link_descr, link_id|
          section_links[link_descr] =  link_id ? fetch_link(link_id) : nil
        end
      end
    end

    def attributes
      @new_admit_attributes ||= {}.tap do |new_admit_attributes|
        new_admit_statuses = CampusSolutions::Sir::SirStatuses.new(@uid).get_feed
        undergraduate_status = new_admit_statuses.try(:[], :sirStatuses).try(:find) {|status| status.try(:[], :isUndergraduate)}
        new_admit_attributes.merge!({
          admitTerm: undergraduate_status.try(:[], :newAdmitAttributes).try(:[], :admitTerm),
          applicationNbr: undergraduate_status.try(:[], :checkListMgmtAdmp).try(:[], :admApplNbr).try(:to_s),
          roles: undergraduate_status.try(:[], :newAdmitAttributes).try(:[], :roles),
          visible: undergraduate_status.present?
        })
      end
    end

    def non_spring_admit(admit_term)
      admit_term.try(:[], :type) != 'Spring'
    end

  end
end
