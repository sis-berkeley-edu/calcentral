module Links
  module CampusLinksFromFileFeatureFlagged
    def is_feature_enabled
      Settings.features.campus_links_from_file
    end
    alias_method(:is_campus_links_from_file_feature_enabled, :is_feature_enabled)
  end
end
