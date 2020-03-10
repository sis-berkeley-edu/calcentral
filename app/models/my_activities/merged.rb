module MyActivities
  class Merged < UserSpecificModel

    include Cache::CachedFeed
    include Cache::UserCacheExpiry
    include Cache::JsonAddedCacher
    include Cache::FilterJsonOutput
    include MergedModel

    def self.providers
      [
        MyActivities::Webcasts,
        MyActivities::CanvasActivities
      ]
    end

    def self.cutoff_date(offset = 10)
      today = Settings.terms.fake_now || Time.zone.today.in_time_zone
      today.to_datetime.advance(days: -offset).to_time.to_i
    end

    def get_feed_internal
      feed = {
        activities: [],
        archiveUrl: cs_dashboard_url
      }

      # Note that some providers require MyActivities::DashboardSites, which in turn has a direct dependency on
      # MyClasses and MyGroups.
      handling_provider_exceptions(feed, self.class.providers) do |provider|
        if provider.respond_to? :append_with_dashboard_sites!
          provider.append_with_dashboard_sites!(@uid, feed[:activities], dashboard_sites)
        else
          provider.append!(@uid, feed[:activities])
        end
      end

      feed
    end

    def cs_dashboard_url
      cs_dashboard_url_feed = CampusSolutions::DashboardUrl.new.get
      cs_dashboard_url_feed && cs_dashboard_url_feed[:feed] && cs_dashboard_url_feed[:feed][:url]
    end

    def dashboard_sites
      MyActivities::DashboardSites.fetch(@uid, @options)
    end

    def filter_for_view_as(feed)
      if authentication_state.authenticated_as_delegate?
        if authentication_state.delegated_privileges[:financial]
          feed[:activities] = feed[:activities].select {|t| (t[:emitter] == 'Campus Solutions') && t[:cs][:isFinaid]}
        else
          feed[:activities] = []
        end
      elsif authentication_state.authenticated_as_advisor?
        feed[:activities].delete_if {|t| t[:emitter] == 'bCourses'}
      end
      feed
    end

  end
end
