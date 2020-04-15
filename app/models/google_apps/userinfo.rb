module GoogleApps
  class Userinfo < Proxy
    require 'google/apis/people_v1'

    def initialize(options = {})
      super options
      @json_filename = 'google_userinfo.json'
    end

    def mock_request
      super.merge(
        method: :get,
        uri_matching: 'https://people.googleapis.com/v1/people/me'
      )
    end

    def user_info
      request(
        service_class: Google::Apis::PeopleV1::PeopleServiceService,
        method_name: 'get_person',
        method_args: ['people/me', {person_fields: 'emailAddresses'}],
        page_limiter: 1
      ).first
    end
  end
end
