module CampusSolutions
  class Link < GlobalCachedProxy

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def xml_filename
      'link_api_multiple.xml'
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
      status = link_resources[:status]

      if url_id
        # Need this due to side-effect of the lift process in normalize_response.
        link_id = url_id.downcase.camelize(:lower).to_sym
        links = link_resources.try(:[], :feed).try(:[], :ucLinkResources)
        if links.blank?
          logger.error "Empty response from CS Link API for link id #{url_id}, with parameters #{placeholders}"
          status = 500
        else
          entry = links.try(:[], :links).try(:[], link_id)
          link = parse_link(url_id, entry, placeholders)
        end
      end
      {
        status: status,
        link: link
      }
    end

    def parse_link(url_id, entry, placeholders)
      if entry.nil?
        logger.debug "Could not retrieve CS link by id #{url_id}, with parameters #{placeholders}"
        return nil
      end

      link = entry.slice(:url, :urlId, :description, :hoverOverText)

      placeholders.try(:each) do |k, v|
        if v.nil?
          logger.debug "Could not set placeholder for #{k} on link id #{url_id}"
          link = nil
          break
        else
          link[:url] = link[:url].gsub("{#{k}}", v)
        end
      end

      if !link.nil?
        # promote properties we're interested in
        entry[:properties].each do |property|
          if property[:name] == 'NEW_WINDOW' && property[:value] == 'Y'
            link[:showNewWindow] = true
          end
          if property[:name] == 'UCFROM'
            link[:ucFrom] = property[:value]
          end
          if property[:name] == 'UCFROMLINK'
            link[:ucFromLink] = property[:value]
          end
          if property[:name] == 'UCFROMTEXT'
            link[:ucFromText] = property[:value]
          end
          if property[:name] == 'LINK_DESCRIPTION'
            link[:linkDescription] = property[:value]
          end
          if property[:name] == 'LINK_DESCRIPTION_DISPLAY'
            link[:linkDescriptionDisplay] = property[:value] == 'Y'
          end
        end

        # convert campus solutions property names to calcentral
        link[:name] = link.delete(:description)
        link[:title] = link.delete(:hoverOverText) || ''
        if !link[:showNewWindow]
          link[:isCsLink] = true
          link['IS_CS_LINK'] = true
        end
      end
      link
    end

    def url
      "#{@settings.base_url}/UC_LINK_API.v1/get?PROPNAME=CALCENTRAL"
    end

  end
end
