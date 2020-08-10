class COVIDUpdates
  def as_json(options={})
    {
      campusUpdates: campus_updates_message,
      resourceLinks: resource_links,
      screener: {
        link: screener_link,
        message: screener_message
      },
    }
  end

  def resource_links
    [
      LinkFetcher.fetch_link('UC_CC_COVID_RESOURCE_URL1'),
      LinkFetcher.fetch_link('UC_CC_COVID_RESOURCE_URL2'),
      LinkFetcher.fetch_link('UC_CC_COVID_RESOURCE_URL3'),
      LinkFetcher.fetch_link('UC_CC_COVID_RESOURCE_URL4'),
      LinkFetcher.fetch_link('UC_CC_COVID_RESOURCE_URL5'),
    ].compact
  end

  def screener_link
    LinkFetcher.fetch_link('UC_CC_COVID_DAILY_SCREENING')
  end

  def campus_updates_message
    CampusSolutions::MessageCatalog.get_message(:covid_campus_updates)
  end

  def screener_message
    CampusSolutions::MessageCatalog.get_message(:covid_screener)
  end
end
