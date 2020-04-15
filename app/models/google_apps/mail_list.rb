module GoogleApps
  class MailList < Proxy

    include Proxies::MockableXml

    def user_authorization
      user_token_data = User::Oauth2Data.get(@uid)
      GoogleApps::Auth::Authorization.refresh_credential(user_token_data)
    end

    # Using Google::Apis::Core::BaseService#http to perform simple HTTP request with
    # OAuth2 token refresh support provided by Google API Client library
    # See https://github.com/googleapis/google-api-ruby-client/blob/0.24.1/lib/google/apis/core/base_service.rb#L220,L253
    def mail_unread
      initialize_mocks if @fake

      service = Google::Apis::Core::BaseService.new('https://mail.google.com/', 'mail/feed/atom/')
      service.authorization = user_authorization
      service.http(:get, 'https://mail.google.com/mail/feed/atom/')
    end

    def mock_request
      super.merge(uri_matching: Settings.google_proxy.atom_mail_feed_url)
    end

    def mock_xml
      read_file('fixtures', 'xml', 'google_mail_list.xml')
    end

  end
end
