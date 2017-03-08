module GoogleApps
  class Userinfo < Proxy

    def initialize(options = {})
      super options
      @json_filename = 'google_userinfo.json'
    end

    def mock_request
      super.merge(
        method: :get,
        uri_matching: 'https://www.googleapis.com/plus/v1/people/me'
      )
    end

    def self.api
      'userinfo'
    end

    def user_info
      request(
        api: 'plus',
        api_version: 'v1',
        resource: 'people',
        method: 'get',
        headers: {
          'Content-Type' => 'application/json'
        },
        params: {
          'userId' => 'me'
        }
      ).first
    end

    def current_scope
      access_granted = case @app_id
                         when GoogleApps::Proxy::APP_ID
                           # Google API call for 'self' to update tokens of current user.
                           (info = user_info) && info.response && info.response.status == 200
                         when GoogleApps::Proxy::OEC_APP_ID
                           # We rely on the invoking controller to verify 'can_administer_oec' privileges.
                           @uid == Settings.oec.google.uid
                         else
                           false
                       end
      return [] unless access_granted

      # Ask Google for scope associated with token
      access_token = authorization.access_token
      request_options = {
        query: {
          access_token: access_token
        }
      }
      response = get_response('https://www.googleapis.com/oauth2/v1/tokeninfo', request_options)
      response['scope'].present? ? response['scope'].split : []
    end

  end
end
