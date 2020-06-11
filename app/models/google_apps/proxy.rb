module GoogleApps
  include ClassLogger

  # Super-class for all Google Apps (G-Suite / bConnected) proxies.
  # See https://wikihub.berkeley.edu/display/SIS/CalCentral+bConnected+Integration
  class Proxy < BaseProxy
    include Proxies::Mockable

    attr_accessor :authorization, :json_filename

    APP_ID = 'Google'

    def self.settings
      Settings.google_proxy
    end

    def initialize(options = {})
      super(Proxy.settings, options)

      @authorization = load_authorization options
      @fake_options = options[:fake_options] || {}
      @current_token = @authorization.access_token
      @start = Time.now.to_f
    end

    def request(request_params={})
      page_params = setup_page_params request_params

      result_pages = Enumerator.new do |yielder|
        logger.info "Making request with @fake = #{@fake}, params = #{request_params}"

        page_token = nil
        under_page_limit_ceiling = true
        num_requests = 0

        begin
          unless page_token.blank?
            page_params[:params]['pageToken'] = page_token
            logger.debug "Making page request with pageToken = #{page_token}"
          end

          page_token, under_page_limit_ceiling, result_page = request_transaction(page_params, num_requests)

          yielder << result_page
          num_requests += 1

          if result_page.blank?
            logger.warn "request stopped on error: #{result_page ? result_page.response.inspect : 'nil'}"
            break
          end
        end while (page_token and under_page_limit_ceiling)
      end
      result_pages
    end

    private

    def load_authorization(options={})
      if @fake
        user_token_data = {}
      elsif options[:user_id]
        user_token_data = User::Oauth2Data.get(@uid)
      end
      GoogleApps::Auth::Authorization.refresh_credential(user_token_data)
    end

    def request_transaction(page_params, num_requests)
      @params = page_params
      initialize_mocks if @fake

      result_page = ActiveSupport::Notifications.instrument('proxy', {class: self.class}) do
        begin
          resource_method = @params[:resource_method]
          service_class = resource_method.fetch(:service_class)
          method_name = resource_method.fetch(:method_name)
          method_args = resource_method.fetch(:method_args)

          service = service_class.new
          service.authorization = @authorization

          if method_args.class == Hash
            service.send(method_name.to_sym, method_args)
          elsif method_args.class == Array
            service.send(method_name.to_sym, *method_args)
          else
            raise ArgumentError, "'method_args' must be a Hash or Array"
          end
        rescue => e
          logger.fatal "#{e.to_s} - Unable to send request transaction"
          nil
        end
      end
      page_token = result_page.try(:next_page_token)
      under_page_limit_ceiling = under_page_limit?(num_requests+1, page_params[:page_limiter])

      [page_token, under_page_limit_ceiling, result_page]
    end

    def setup_page_params(request_params)
      resource_method = {
        service_class: request_params[:service_class],
        method_name: request_params[:method_name],
        method_args: request_params[:method_args]
      }
      {
        params: request_params[:params],
        body: request_params[:body],
        headers: request_params[:headers],
        resource_method: resource_method,
        page_limiter: request_params[:page_limiter]
      }
    end

    def self.access_granted?(user_id)
      Proxy.settings.fake || User::Oauth2Data.get(user_id)[:access_token].present?
    end

    def under_page_limit?(current_pages, page_limit)
      if page_limit && page_limit.is_a?(Integer)
        current_pages < page_limit
      else
        true
      end
    end

    def mock_json
      read_file('fixtures', 'json', json_filename)
    end
  end
end
