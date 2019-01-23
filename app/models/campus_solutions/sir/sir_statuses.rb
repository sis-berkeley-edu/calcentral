module CampusSolutions
  module Sir
    class SirStatuses < UserSpecificModel

      include Berkeley::TermCodes
      include Cache::CachedFeed
      include Cache::UserCacheExpiry
      include Cache::RelatedCacheKeyTracker
      include Concerns::DatesAndTimes
      include LinkFetcher
      include User::Identifiers

      HEADER_DATA = {
        GENERIC: {
          background: 'cc-widget-sir-background-berkeley'
        },
        GRADDIV: {
          name: 'Fiona M. Doyle',
          title: 'Dean of the Graduate Division',
          background: 'cc-widget-sir-background-berkeley',
          picture: 'cc-widget-sir-picture-grad'
        },
        HAASGRAD: {
          name: 'Richard Lyons',
          title: 'Haas School of Business, Dean',
          background: 'cc-widget-sir-background-haasgrad',
          picture: 'cc-widget-sir-picture-haasgrad'
        },
        LAW: {
          background: 'cc-widget-sir-background-lawjd'
        },
        UGRD: {
          name: 'Olufemi Ogundele',
          title: 'Assistant Vice Chancellor & Director',
          background: 'cc-widget-sir-background-berkeley',
          picture: 'cc-widget-sir-picture-ugrad'
        }
      }

      LINK_IDS = {
        coaFreshmanLink: 'UC_ADMT_COND_FRESH',
        coaTransferLink: 'UC_ADMT_COND_TRANS',
        firstYearPathwayLink: 'UC_ADMT_FYP_SELECT'
      }

      def get_feed_internal
        sir_items = active_application_nbrs.length ? get_checklist_items : []
        {
          sirStatuses: sir_items
        }
      end

      def get_checklist_items
        checklist_feed = CampusSolutions::MyChecklist.new(@uid).get_feed
        checklist_items = checklist_feed.try(:[], :feed).try(:[], :checkListItems)
        if checklist_items.nil?
          return nil
        else
          extract_sir_checklist_items(checklist_items)
        end
      end

      def extract_sir_checklist_items(checklist_items)
        sir_checklist_items = []
        checklist_items.try(:each) do |checklist_item|
          sir_checklist_items.push(checklist_item) if checklist_item.try(:[], :adminFunc) == 'ADMP' && is_active_offer?(checklist_item)
        end
        filtered_sir_items = filter_duplicate_items(sir_checklist_items)
        map_sir_configs(filtered_sir_items)
      end

      def filter_duplicate_items(sir_checklist_items)
        unique_sir_checklist_items = sir_checklist_items.uniq { |item| item[:checkListMgmtAdmp][:admApplNbr] }
        if unique_sir_checklist_items.length == sir_checklist_items.length
          sir_checklist_items
        else
          duplicate_application_nbrs = (sir_checklist_items - unique_sir_checklist_items).map { |item| item[:checkListMgmtAdmp][:admApplNbr] }.uniq
          # create an array with the structure [[dup-a1, dup-a2], [dup-b1, dup-b2], [dup-c1, dup-c2, dup-c3, ...], ...]
          duplicate_item_sets = []
          duplicate_application_nbrs.each do |duplicate_nbr|
            duplicate_item_sets.push(sir_checklist_items.select { |checklist_item| checklist_item[:checkListMgmtAdmp][:admApplNbr] == duplicate_nbr })
          end
          # reduce each subarray to the checklist item with the highest SEQ_3C
          picked_from_duplicates = duplicate_item_sets.map { |item_set| item_set.sort_by! { |item| item[:checklistSeq].to_i }.last }
          # remove unwanted duplicates from returned array
          picked_from_duplicates.each do |picked|
            sir_checklist_items.delete_if do |item|
              picked[:checkListMgmtAdmp][:admApplNbr] == item[:checkListMgmtAdmp][:admApplNbr] &&
              picked[:checklistSeq] != item[:checklistSeq]
            end
          end
          sir_checklist_items
        end
      end

      def map_sir_configs(sir_checklist_items)
        sir_config = (CampusSolutions::Sir::SirConfig.new().get).try(:[], :feed).try(:[], :sirConfig)
        sir_checklist_items.delete_if do |item|
          relevant_sir_config = find_relevant_sir_config_form(item, sir_config.try(:[], :sirForms))
          if relevant_sir_config.present?
            item[:config] = relevant_sir_config
            item[:responseReasons] = find_relevant_response_reasons(item, sir_config.try(:[], :responseReasons))
            item[:isUndergraduate] = item.try(:[], :checkListMgmtAdmp).try(:[], :acadCareer) == 'UGRD'
          end
          relevant_sir_config.nil?
        end
        add_status_for_completed_non_undergraduate_items(sir_checklist_items)
      end

      # Some populations are given the option to accept or decline their SIR
      # We need to attach the appropriate messaging from the SIR config for these
      def add_status_for_completed_non_undergraduate_items(sir_checklist_items)
        sir_checklist_items.each do |item|
          next unless is_completed_non_undergraduate_item?(item)
          application_nbr = item.try(:[], :checkListMgmtAdmp).try(:[], :admApplNbr).try(:to_s)

          if (application_attributes = applications[application_nbr])
            action = application_attributes.try(:[], :admitAction)
            sirOptions = item.try(:[], :config).try(:[], :sirOptions) || []
            message = (sirOptions.find { |option| option.try(:[], :progAction) == action }).try(:[], :messageText)

            item[:sirCompletedAction] = action
            item[:sirCompletedMessage] = message
          end
        end
        add_deposit_info(sir_checklist_items)
      end

      def add_deposit_info(sir_checklist_items)
        sir_checklist_items.try(:each) do |item|
          deposit = { required: false }
          if is_incomplete? item
            adm_appl_nbr = item.try(:[], :checkListMgmtAdmp).try(:[], :admApplNbr).try(:to_s)
            deposit_info = unpack_deposit_response MyDeposit.new(@uid, adm_appl_nbr: adm_appl_nbr).get_feed
            deposit.merge!(deposit_info)
            deposit[:required] = deposit_due? deposit.try(:[], :dueAmt)
          end
          item[:deposit] = deposit
        end
        add_undergraduate_new_admit_attributes(sir_checklist_items)
      end

      def add_undergraduate_new_admit_attributes(sir_checklist_items)
        sir_checklist_items.try(:each) do |item|
          new_admit_attributes = {}
          if item.try(:[], :isUndergraduate)
            application_nbr = item.try(:[], :checkListMgmtAdmp).try(:[], :admApplNbr).try(:to_s)
            new_admit_attributes.merge!(get_undergraduate_new_admit_attributes(application_nbr))
            if is_completed_undergraduate_item? item
              new_admit_attributes.merge!( {links: get_undergraduate_new_admit_links(new_admit_attributes[:roles])} )
            end
          end
          item[:newAdmitAttributes] = new_admit_attributes
        end
        add_header_info(sir_checklist_items)
      end

      def get_undergraduate_new_admit_attributes(application_nbr)
        if (application_attributes = applications[application_nbr])
          first_year_freshman = application_attributes.try(:[], :admitType) == 'FYR'
          is_athlete = application_attributes.try(:[], :athlete) == 'Y'
          is_global_edge = application_attributes.try(:[], :globalEdgeProgram) == 'Y'
          admit_term = application_attributes.try(:[], :admitTerm)

          roles = {
            athlete: is_athlete,
            firstYearFreshman: first_year_freshman,
            firstYearPathway: first_year_freshman && !is_athlete && !is_global_edge && ['UCLS', 'UCNR'].include?(application_attributes.try(:[], :applicantProgram)),
            preMatriculated: ['AD', 'PM'].include?(application_attributes.try(:[], :admitStatus)),
            transfer: application_attributes.try(:[], :admitType) == 'TRN'
          }
          term = {
            term: admit_term,
            type: codes[from_edo_id(admit_term).try(:[], :term_cd).to_sym]
          }
          { roles: roles, admitTerm: term }
        end
      end

      def get_undergraduate_new_admit_links(new_admit_roles)
        return {} unless new_admit_roles
        link_configuration = {
          coaFreshmanLink: new_admit_roles[:firstYearFreshman],
          coaTransferLink: new_admit_roles[:transfer],
          firstYearPathwayLink: new_admit_roles[:firstYearPathway]
        }
        add_undergraduate_new_admit_links link_configuration
      end

      def add_undergraduate_new_admit_links(link_configuration)
        links = {}
        link_configuration.try(:each) do |link_key, link_visible|
          if link_visible
            link = fetch_link(LINK_IDS[link_key])
            links[link_key] = link
          end
        end
        link_configuration.merge!(links)
      end

      def add_header_info(sir_checklist_items)
        sir_checklist_items.try(:each) do |item|
          header_cd = (item.try(:[], :config).try(:[], :ucSirImageCd)).try(:to_sym)
          header_info = header_cd.nil? ? HEADER_DATA.try(:[], :GENERIC) : HEADER_DATA.try(:[], header_cd)
          item[:header] = header_info
        end
      end

      def applications
        @applications ||= {}.tap do |applications|
          all_applicant_data = EdoOracle::Queries.get_new_admit_data(campus_solutions_id) || []
          all_applicant_data.each do |application|
            if (application_nbr = application.try(:[], 'application_nbr'))
              applications[application_nbr] = HashConverter.camelize(application)
            end
          end
        end
      end

      def active_application_nbrs
        @active_applications ||= [].tap do |active_applications|
          current_date = Settings.terms.fake_now || DateTime.now
          applications.each do |application_nbr, application|
            expiration_date = application.try(:[], :expirationDate)
            expiration_date = cast_utc_to_pacific(expiration_date) if expiration_date.present?

            if expiration_date && current_date <= expiration_date + 1.days
              active_applications.push(application_nbr) unless active_applications.include?(application_nbr)
            end
          end
        end
      end

      def campus_solutions_id
        @campus_solutions_id ||= lookup_campus_solutions_id(@uid)
      end

      def is_active_offer?(checklist_item)
        checklist_application_nbr = checklist_item.try(:[], :checkListMgmtAdmp).try(:[], :admApplNbr).try(:to_s)
        active_application_nbrs.include?(checklist_application_nbr)
      end

      def is_incomplete?(checklist_item)
        ['I', 'R'].include?(checklist_item.try(:[], :itemStatusCode))
      end

      def is_completed_undergraduate_item?(checklist_item)
        checklist_item.try(:[], :itemStatusCode) == 'C' || (checklist_item.try(:[], :itemStatusCode) == 'R' && !checklist_item.try(:[], :deposit).try(:[], :required))
      end

      def is_completed_non_undergraduate_item?(checklist_item)
        checklist_item.try(:[], :checkListMgmtAdmp).try(:[],  :acadCareer) != 'UGRD' && checklist_item.try(:[], :itemStatusCode) == 'C'
      end

      def unpack_deposit_response(deposit_response)
        deposit_response.try(:[], :feed).try(:[], :depositResponse).try(:[], :deposit)
      end

      def deposit_due?(deposit_amt)
        !deposit_amt.nil? && deposit_amt != 0
      end

      def find_relevant_sir_config_form(checklist_item, sir_config_forms)
        sir_config_forms.try(:find) do |form|
          form.try(:[], :chklstItemCd) == checklist_item.try(:[], :chklstItemCd)
        end
      end

      def find_relevant_response_reasons(checklist_item, sir_config_response_reasons)
        sir_config_response_reasons.try(:select) do |reason|
          reason.try(:[], :acadCareer) == checklist_item.try(:[], :config).try(:[], :acadCareer)
        end
      end

    end
  end
end
