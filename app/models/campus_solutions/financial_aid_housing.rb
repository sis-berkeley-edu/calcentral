module CampusSolutions
  module FinancialAidHousing

    INSTRUCTIONAL_MESSAGE_NUMBERS = {
      generic: '117',
      fall_pathways: '116',
      spring_pathways: '118'
    }
    def self.append_housing(uid, feed)
      if feed.try(:[], :feed).try(:[], :housing)
        @uid = uid
        undergrad_status = find_undergrad_new_admit_status
        undergrad_new_admit_attributes = undergrad_status.try(:[], :newAdmitAttributes)

        feed[:feed][:housing][:instruction] = instruction(undergrad_status, undergrad_new_admit_attributes)

        if (link = feed[:feed][:housing].try(:[], :link)).try(:has_key?, :title)
          feed[:feed][:housing][:link] = update_housing_link(link, undergrad_new_admit_attributes)
          feed[:feed][:housing].merge! first_year_pathway_items(undergrad_new_admit_attributes)
        end
      end
      feed
    end

    def self.update_housing_link(link, undergrad_new_admit_attributes)
      return nil unless undergrad_new_admit_attributes.present? || continuing_undergrad?

      if first_year_fall_admit? undergrad_new_admit_attributes
        return {
          title: 'Update Housing or First-Year Pathway',
          name: 'Update Housing / Pathway',
          url: link.try(:[], :url),
          isCsLink: link.try(:[], :isCsLink)
        }
      end
      {
        title: 'Update Housing',
        name: 'Update Housing',
        url: link.try(:[], :url),
        isCsLink: link.try(:[], :isCsLink)
      }
    end

    def self.first_year_pathway_items(undergrad_new_admit_attributes)
      pathways_link = LinkFetcher.fetch_link('UC_ADMT_FYPATH_FA_SPG') if first_year_spring_admit? undergrad_new_admit_attributes
      pathways_message = get_message :spring_pathways if first_year_spring_admit? undergrad_new_admit_attributes

      items = {
        pathways_link: pathways_link,
        pathways_message: pathways_message
      }
      items[:title] = 'Housing or Pathway' if first_year_fall_admit? undergrad_new_admit_attributes
      items
    end

    def self.instruction(undergrad_status, undergrad_new_admit_attributes)
      return get_message :fall_pathways if first_year_fall_admit? undergrad_new_admit_attributes
      return get_message :generic if undergrad_status
    end

    def self.find_undergrad_new_admit_status
      sir_status_feed = CampusSolutions::Sir::SirStatuses.new(@uid).get_feed
      sir_statuses = sir_status_feed.try(:[], :sirStatuses)
      sir_statuses.try(:find) {|status| status[:isUndergraduate]}
    end

    def self.continuing_undergrad?
      is_undergrad = User::AggregatedAttributes.new(@uid).get_feed[:roles][:undergrad]
      is_continuing = !MyAcademics::MyAcademicRoles.new(@uid).get_feed[:current]['ugrdNonDegree']
      is_undergrad && is_continuing
    end

    def self.first_year_fall_admit?(undergrad_new_admit_attributes)
      first_year_pathway = undergrad_new_admit_attributes.try(:[], :roles).try(:[], :firstYearPathway)
      admit_term = undergrad_new_admit_attributes.try(:[], :admitTerm)
      first_year_pathway && admit_term.try(:[], :type) == 'Fall'
    end

    def self.first_year_spring_admit?(undergrad_new_admit_attributes)
      first_year_pathway = undergrad_new_admit_attributes.try(:[], :roles).try(:[], :firstYearPathway)
      admit_term = undergrad_new_admit_attributes.try(:[], :admitTerm)
      first_year_pathway && admit_term.try(:[], :type) == 'Spring'
    end

    def self.get_message(type)
      CampusSolutions::MessageCatalog.get_message_catalog_definition('26500', INSTRUCTIONAL_MESSAGE_NUMBERS[type])
    end
  end
end
