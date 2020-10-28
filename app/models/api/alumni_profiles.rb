class  Api::AlumniProfiles < UserSpecificModel
  include Cache::CachedFeed
  include Cache::UserCacheExpiry


  def get_feed_internal
    {
      landing_page_sub_title:  self.class.landing_page_sub_title,
      landing_page_message:   self.class.landing_page_message,
      homepage_link:  self.class.homepage_link,
      skip_landing_page: skip_landing_page?
    }
  end


  def set_skip_landing_page
    AlumniProfile.create(uid: @uid) unless skip_landing_page?
    Api::AlumniProfiles.expire(@uid)
  end

  def skip_landing_page?
    AlumniProfile.find_by(uid: @uid).present?
  end

  def self.landing_page_sub_title
     CampusSolutions::MessageCatalog.get_message(:alumni_landing_page_sub_title)
  end
  
  def self.landing_page_message
    CampusSolutions::MessageCatalog.get_message(:alumni_landing_page_message)
  end

  def self.homepage_link
    LinkFetcher.fetch_link('UC_CC_SS_ALUM_HOMEPAGE')
  end
end
