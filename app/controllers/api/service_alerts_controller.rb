class Api::ServiceAlertsController < Api::BaseController
  before_action :require_author
  skip_before_action :require_author, only: [:public_feed]
  before_action :service_alert, except: [:public_feed, :index, :create]

  def public_feed
    render json: Api::ServiceAlerts.new.get_feed
  end

  def index
    scope = ServiceAlert
    scope = scope.displayed if params[:displayed]
    scope = scope.order(publication_date: :desc)
    scope = scope.page(params[:page])

    render json: {
      current_page: scope.current_page,
      service_alerts: scope,
      total_pages: scope.total_pages,
    }
  end

  def show
    @service_alert = ServiceAlert.find(params[:id])
    render json: @service_alert
  end

  def create
    @service_alert = ServiceAlert.new service_alert_params

    if @service_alert.save
      render json: @service_alert, status: :created
    else
      render json: @service_alert.errors, status: :unprocessable_entity
    end
  end

  def update
    if service_alert.update_attributes service_alert_params
      render json: service_alert, status: :ok
    else
      render json: @service_alert.errors, status: :unprocessable_entity
    end
  end

  def destroy
    service_alert.destroy
  end

  private

  def service_alert
    @service_alert ||= ServiceAlert.find params[:id]
  end

  def service_alert_params
    params.require(:service_alert).permit(
      :title,
      :body,
      :snippet,
      :publication_date,
      :display,
      :splash_only
    )
  end
end
