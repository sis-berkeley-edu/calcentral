module FinancialAid
  class MyAwards < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::RelatedCacheKeyTracker
    include CampusSolutions::FinaidFeatureFlagged
    include LinkFetcher


    def get_feed_internal
      return {} unless is_feature_enabled
      {
        awards: awards,
        messages: {
          messageInfo: CampusSolutions::MessageCatalog.get_message(:financial_aid_awards_card_info).try(:[], :descrlong),
          messageEstDisbursements: CampusSolutions::MessageCatalog.get_message(:financial_aid_awards_card_info_est_disbursements).try(:[], :descrlong)
        },
        linkFinaidTranscript: fetch_link('UC_CX_FA_FIN_AID_SUMMARY', link_params)
      }
    end

    def instance_key
      "#{@uid}-#{my_aid_year}"
    end

    private

    def awards
      return nil unless all_awards
      {
        giftaid: get_awards_giftaid(),
        waiversAndOther: get_awards('waiversAndOther', 'Waivers and Other Funding'),
        workstudy: get_awards('workstudy', 'Work-Study'),
        subsidizedloans: get_awards('subsidizedloans', 'Subsidized Loans'),
        unsubsidizedloans: get_awards('unsubsidizedloans', 'Unsubsidized Loans'),
        plusloans: get_awards('plusloans', 'PLUS Loans'),
        alternativeloans: get_awards('alternativeloans', 'Alternative Loans'),
        grandtotal: grand_total,
        hasLoans: has_loans?,
        loans: links('loans')
      }
    end

    def my_aid_year
      @my_aid_year ||= (@options[:aid_year] || FinancialAid::MyAidYears.new(@uid).default_aid_year).to_i.to_s
    end

    def all_awards
      @all_awards ||= EdoOracle::FinancialAid::Queries.get_awards(@uid, my_aid_year)
    end

    def grand_total
      grand_total = EdoOracle::FinancialAid::Queries.get_awards_total(@uid, my_aid_year)
      return nil unless grand_total
      total = {
        total: {
          amount: grand_total[0]['total'].to_f,
          title: 'Grand Total'
        }
      }
    end

    def get_awards_giftaid()
      # Gift Aid is unique in that if none exists for the student, we still want the section to show because
      # it includes a link for student to Report Outside Resources.  However, if the link is turned off
      # in the Campus Solutions configuration we do not want the link to show
      return nil unless (EdoOracle::FinancialAid::Queries.get_awards_total_by_type(@uid, my_aid_year, 'giftaid')[0]['total'].to_f > 0 || outside_resources_available?)
      {
        total: award_total('giftaid', 'Gift Aid'),
        items: award_items('giftaid'),
        links: links('giftaid')
      }
    end

    def get_awards(award_type, award_title)
      return nil unless EdoOracle::FinancialAid::Queries.get_awards_total_by_type(@uid, my_aid_year, award_type)[0]['total'].to_f > 0
      {
        total: award_total(award_type, award_title),
        items: award_items(award_type),
        links: links(award_type)
      }
    end

    def award_total(award_type, award_title)
      award_total = EdoOracle::FinancialAid::Queries.get_awards_total_by_type(@uid, my_aid_year, award_type)
      return nil unless award_total
      {
        amount: award_total[0]['total'].to_f,
        title: award_title
      }
    end

    def award_items(award_type)
      all_awards.select { |award| award['award_type'] === award_type}.map.try(:each) do |item|
      {
        title: item['title'],
        subtitle: item['subtitle'],
        leftColumn: {
          amount: item['left_col_amt'].to_f,
          value: item['left_col_val']
        },
        rightColumn: {
          amount: item['right_col_amt'].to_f,
          value: item['right_col_val'],
          link: accept_loans_link(item['item_type'])
        },
        subItems: sub_items(award_type, item)
      }
      end
    end

    def accept_loans_link(item_type)
      if loans_acceptable?(item_type)
        accept_loans_link = {
          url: fetch_link('UC_CX_FA_AWRD_AWD_MGT', link_params)[:url],
          title: "Accept",
          isCsLink: true
        }
      end
    end

    def links(award_type)
      case award_type
      when 'giftaid'
        if outside_resources_available?
          links = [
            url: fetch_link('UC_CX_FA_AWRD_ADDL_SRC', link_params)[:url],
            title: "Report Outside Resources",
            isCsLink: true
          ]
        end

      when 'loans'
        if loans_reducable_cancelable?
          links = [
            {
              url: fetch_link('UC_CX_FA_AWRD_RDC_CNCL', link_params)[:url],
              title: "Reduce/Cancel",
              isCsLink: true
            }
          ]
        else
          links = []
        end

        if loans_convertable?
          links_convertable =
          {
            url: fetch_link('UC_CX_FA_AWRD_CONV_AID_L2W', link_params)[:url],
            title: "Convert to Work-Study",
            isCsLink: true
          }

          links ? links.push(links_convertable) : links = links_convertable
        end

        links

      when 'workstudy'
        links = [
          {
            url: 'http://financialaid.berkeley.edu/work-study',
            title: 'Find a Job',
            isCsLink: false
          }
        ]

        if workstudy_convertable?
          fluid_link = {
            url: fetch_link('UC_CX_FA_AWRD_CONV_AID_W2L', link_params)[:url],
            title: "Convert to Loan(s)",
            isCsLink: true
          }

          links.push(fluid_link)
        else
          links
        end
      else
        links = []
      end

      links
    end

    def link_params
      {
        AID_YEAR: my_aid_year,
        INSTITUTION: 'UCB01'
      }
    end

    def sub_items(award_type, item)
      unless award_type === 'workstudy'
        {
          alertDetails: alert_details(item['item_type']),
          termDetails: disbursements(item['item_type']),
          awardMessage: item['award_message'],
          authFailedMessage: auth_failed_message(item['item_type']),
          itemTypeDescr: item['title']
        }
      else
        {
          alertDetails: alert_details(item['item_type']),
          remainingAmount: (item['left_col_amt'] - item['right_col_amt']).to_f,
          awardMessage: item['award_message'],
          authFailedMessage: auth_failed_message(item['item_type']),
          itemTypeDescr: item['title']
        }
      end
    end

    def has_loans?
      !!EdoOracle::FinancialAid::Queries.get_awards_has_loans(@uid, my_aid_year)
    end

    def outside_resources_available?
      !!EdoOracle::FinancialAid::Queries.get_awards_outside_resources(my_aid_year)
    end

    def loans_acceptable?(item_type)
      !!EdoOracle::FinancialAid::Queries.get_awards_accept_loans(@uid, my_aid_year, item_type)
    end

    def loans_reducable_cancelable?
      !!EdoOracle::FinancialAid::Queries.get_awards_reduce_cancel(@uid, my_aid_year)
    end

    def loans_convertable?
      !!EdoOracle::FinancialAid::Queries.get_awards_convert_loan_to_wks(@uid, my_aid_year)
    end

    def workstudy_convertable?
      !!EdoOracle::FinancialAid::Queries.get_awards_convert_wks_to_loan(@uid, my_aid_year)
    end

    def auth_failed_message_exists?(item_type)
      !!EdoOracle::FinancialAid::Queries.get_auth_failed_message(@uid, my_aid_year, item_type)
    end

    def auth_failed_message(item_type)
      return nil unless auth_failed_message_exists?(item_type)
      CampusSolutions::MessageCatalog.get_message(:financial_aid_awards_card_auth_failed).try(:[], :descrlong)
    end

    def alert_details(item_type)
      alert_details = EdoOracle::FinancialAid::Queries.get_awards_alert_details(@uid, my_aid_year, item_type)
        return [] unless alert_details
        alert_details.map.try(:each) do |item|
        {
          alertMessage: item['alert_message'],
          alertTerm: item['alert_term']
        }
      end
    end

    def disbursements(item_type)
      if item_type
        disbursements = EdoOracle::FinancialAid::Queries.get_awards_disbursements(@uid, my_aid_year, item_type)
      else
        disbursements = EdoOracle::FinancialAid::Queries.get_awards_disbursements_tuition_fee_remission(@uid, my_aid_year)
      end

        return [] unless disbursements
        disbursements.map.try(:each) do |item|
        {
          term: item['term'],
          disbursementid: item['disbursementid'],
          offered: item['offered'].to_f,
          disbursed: item['disbursed'].to_f,
          disbursementDate: item['disbursement_date'].to_s
        }
      end
    end
  end
end
