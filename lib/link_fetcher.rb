module LinkFetcher
  extend self
  include ClassLogger

  def fetch_link(link_key, placeholders = {})
    link_feed(link_key, placeholders).try(:fetch, :link)
  end

  def link_feed(link_key, placeholders = {})
    link_feed = CampusSolutions::Link.new.get_url link_key
    if (link = link_feed.try(:fetch, :link))
      replace_url_params(link_key, link, placeholders)
      link_feed[:link] = link
    else
      logger.debug "Could not parse CS link response for id #{link_key}, params: #{placeholders}"
    end
    link_feed
  end

  def replace_url_params(link_key, link, placeholders)
    placeholders.try(:each) do |k, v|
      if v.nil?
        logger.debug "Could not set url parameter #{k} on link id #{link_key}"
      else
        link[:url] = link[:url].gsub("{#{k}}", v)
      end
    end
  end
end
