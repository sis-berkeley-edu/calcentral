module CampusSolutions
  module FinancialAidHousing

    INSTRUCTIONAL_MESSAGE_NUMBERS = {
      generic: '117',
      fall_pathways: '116',
      spring_pathways: '118'
    }
    def self.append_housing(uid, feed)
      if feed.try(:[], :feed).try(:[], :housing)
        message_type = nil
        if link_title_present = feed[:feed][:housing].try(:[], :link).try(:has_key?, :title)
          feed[:feed][:housing][:link][:name] = 'Update Housing'
          feed[:feed][:housing][:link][:title] = 'Update Housing'
        end

        sir_status_feed = CampusSolutions::Sir::SirStatuses.new(uid).get_feed
        sir_statuses = sir_status_feed.try(:[], :sirStatuses)
        if sir_statuses.present? && ugrd_status = sir_statuses.find {|status| status[:isUndergraduate]}

          message_type = :generic
          new_admit_attributes = ugrd_status.try(:[], :newAdmitAttributes)

          first_year_pathway = new_admit_attributes.try(:[], :roles).try(:[], :firstYearPathway)
          admit_term = new_admit_attributes.try(:[], :admitTerm)
          if first_year_pathway

            if admit_term.try(:[], :type) == 'Fall'
              message_type = :fall_pathways
              feed[:feed][:housing][:title] = 'Housing or Pathway'
              if link_title_present
                feed[:feed][:housing][:link][:title] = 'Update Housing or First-Year Pathway'
                feed[:feed][:housing][:link][:name] = 'Update Housing / Pathway'
              end
            end
            if admit_term.try(:[], :type) == 'Spring'
              if link_title_present
                pathways_link = LinkFetcher.fetch_link('UC_ADMT_FYPATH_FA_SPG')
                pathways_message = CampusSolutions::MessageCatalog.get_message_catalog_definition('26500', INSTRUCTIONAL_MESSAGE_NUMBERS[:spring_pathways])
                feed[:feed][:housing][:pathways_link] = pathways_link
                feed[:feed][:housing][:pathways_message] = pathways_message
              end
            end
          end
        else
          feed[:feed][:housing].delete(:link)
        end
        if message_type
          instruction = CampusSolutions::MessageCatalog.get_message_catalog_definition('26500', INSTRUCTIONAL_MESSAGE_NUMBERS[message_type])
          feed[:feed][:housing][:instruction] = instruction
        end
      end
      feed
    end
  end
end
