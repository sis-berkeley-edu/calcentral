module LinkFetcher
  extend self
  include ClassLogger

  def fetch_link(link_key, placeholders = {})
    if (link_feed = CampusSolutions::Link.new.get_url link_key, placeholders)
      link = link_feed.try(:fetch, :link)
    end
    logger.debug "Could not parse CS link response for id #{link_key}, params: #{placeholders}" unless link
    link
  end
end
