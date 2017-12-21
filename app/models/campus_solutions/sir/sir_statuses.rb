module CampusSolutions
  module Sir
    class SirStatuses < UserSpecificModel

      include Cache::CachedFeed
      include Cache::UserCacheExpiry
      include SirFeatureFlagged

      HEADER_DATA = {
        DEFAULT: {
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
          name: 'Amy W. Jarich',
          title: 'Assistant Vice Chancellor & Director',
          background: 'cc-widget-sir-background-berkeley',
          picture: 'cc-widget-sir-picture-ugrad'
        }
      }

      def get_feed_internal
        sir_checklist_items = get_sir_checklist_items
        {
          sirStatuses: sir_checklist_items
        }
      end

      def get_sir_checklist_items
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
          sir_checklist_items.push(checklist_item) if checklist_item.try(:[], :adminFunc) == 'ADMP'
        end
        map_sir_configs(sir_checklist_items)
      end

      def map_sir_configs(sir_checklist_items)
        sir_config = (CampusSolutions::Sir::SirConfig.new().get).try(:[], :feed).try(:[], :sirConfig)
        sir_checklist_items.try(:delete_if) do |item|
          relevant_sir_config = find_relevant_sir_config_form(item, sir_config.try(:[], :sirForms))
          if not relevant_sir_config.nil?
            item[:config] = relevant_sir_config
            item[:responseReasons] = find_relevant_response_reasons(item, sir_config.try(:[], :responseReasons))
          end
          relevant_sir_config.nil?
        end
        add_header_info(sir_checklist_items)
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

      def add_header_info(sir_checklist_items)
        sir_checklist_items.try(:each) do |item|
          header_cd = (item.try(:[], :config).try(:[], :ucSirImageCd)).try(:to_sym)
          header_info = header_cd.nil? ? HEADER_DATA.try(:[], :DEFAULT) : HEADER_DATA.try(:[], header_cd)
          item[:header] = header_info
        end
      end


    end
  end
end
