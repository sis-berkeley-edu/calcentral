class RoutesListController < ApplicationController
  extend Cache::Cacheable

  respond_to :json

  def smoke_test_routes
    authorize(current_user, :can_administrate?)
    respond_with({routes: get_smoke_test_routes})
  end

  private

  def get_smoke_test_routes
    routes = %w(
      /api/my/am_i_logged_in
      /api/my/status
      /api/ping
      /api/server_info
      /api/my/academics
      /api/my/activities
      /api/my/badges
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
    routes
  end
end
