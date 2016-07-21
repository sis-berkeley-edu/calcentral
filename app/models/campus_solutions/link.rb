module CampusSolutions
  class Link < GlobalCachedProxy

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def xml_filename
      'link_api.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      normalize_response(response)
    end

    def normalize_response(response)
      # Make sure response is well-structured.
      container = response.parsed_response
      return container if container['UC_LINK_RESOURCES'].blank? || container['UC_LINK_RESOURCES']['IS_FAULT'].present?

      # Lift any Link elements into a single Links element hash on UC_LINK_RESOURCES.
      links = Array.wrap container['UC_LINK_RESOURCES'].delete('Link')
      container['UC_LINK_RESOURCES']['Links'] = links.inject({}) do |map, link|
        map[link['URL_ID']] = link
        map
      end

      container
    end

    def get_url(url_id, placeholders = {})
      # get cached response
      link_resources = get

      if url_id
        # Need this due to side-effect of the lift process in normalize_response.
        link_id = url_id.downcase.camelize(:lower).to_sym
        link = link_resources[:feed][:ucLinkResources][:links][link_id]

        if link
          if placeholders.present?
            placeholders.each do |k, v|
              link[:url] = link[:url].gsub("{#{k}}", v)
            end
          end

          link[:properties].each do |property|
            if property[:name] == 'NEW_WINDOW' && property[:value] == 'Y'
              link[:show_new_window] = true
            end
          end
        end
      end

      {
        status: link_resources[:status],
        feed: {
          link: link
        }
      }
    end

    def url
      "#{@settings.base_url}/UC_LINK_API.v1/get?PROPNAME=CALCENTRAL"
    end

  end
end
