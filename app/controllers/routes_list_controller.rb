class RoutesListController < ApplicationController
  extend Cache::Cacheable

  respond_to :json

  def smoke_test_routes
    authorize(current_user, :can_administrate?)
    respond_with({routes: get_smoke_test_routes})
  end

  private

  def get_smoke_test_routes
    provided_services = Settings.application.provided_services
    routes = %w(
      /api/my/am_i_logged_in
      /api/my/status
      /api/ping
      /api/server_info
    )
    if provided_services.include? 'calcentral'
      routes.concat %w(
        /api/my/academics
        /api/my/activities
        /api/my/badges
        /api/my/cal1card
        /api/my/campuslinks
        /api/my/classes
        /api/my/financials
        /api/my/groups
        /api/my/photo
        /api/my/tasks
        /api/my/up_next
        /api/my/updated_feeds
        /api/service_alerts
        /api/stats
      )
    end
    if provided_services.include? 'bcourses'
      routes.concat %w(
        /api/academics/canvas/external_tools
        /api/academics/canvas/user_can_create_site
      )
    end
    routes
  end
end
