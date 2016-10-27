module GoogleApps
  require 'google/api_client'

  class Client

    include ClassLogger

    class << self
      def client
        @client ||= Google::APIClient.new(options={
          application_name: 'CalCentral',
          application_version: 'v1',
          auto_refresh_token: true,
          retries: 3
        })
      end

      def discover_resource_method(api, api_version, resource, method)
        begin
          discover_api(api, api_version).send(resource.to_sym).send(method.to_sym)
        rescue => e
          logger.fatal "#{name}: #{e.to_s} - Unable to resolve resource method"
          nil
        end
      end

      def new_fake_auth(app_id)
        new_auth(app_id, 'fake_access_token')
      end

      def new_client_auth(app_id, options={})
        new_auth(app_id, options[:access_token], options)
      end

      def generate_request_hash(page_params)
        request_hash = {
          :api_method => page_params[:resource_method]
        }
        request_hash[:parameters] = page_params[:params] unless page_params[:params].blank?
        request_hash[:body] = page_params[:body] unless page_params[:body].blank?
        request_hash[:headers] = page_params[:headers] unless page_params[:headers].blank?
        request_hash
      end

      def request_page(authorization, page_params)
        request_hash = generate_request_hash page_params
        client = GoogleApps::Client.client.dup
        client.authorization = authorization
        request = client.generate_request(options=request_hash)
        client.execute(request)
      end

      private

      def new_auth(app_id, access_token, options={})
        settings = GoogleApps::Proxy.config_of app_id
        authorization = client.authorization.dup
        authorization.client_id = settings.client_id
        authorization.client_secret = settings.client_secret
        authorization.access_token = access_token
        # Not setting these in explicit fake mode will prevent the api_client from attempting to refresh tokens.
        if options && options[:refresh_token] && options[:expiration_time]
          authorization.refresh_token = options[:refresh_token]
          authorization.expires_in = 3600
          authorization.issued_at = Time.at(options[:expiration_time] - 3600)
        end
        authorization
      end

      def discover_version(api)
        client.preferred_version(api).version
      end

      def discover_api(api, api_version=nil)
        api_version ||= discover_version(api)
        client.discovered_api(api, api_version)
      end
    end
  end
end
