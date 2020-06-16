module GoogleApps
  class DriveList < Proxy
    require 'google/apis/drive_v2'

    def initialize(options = {})
      super options
      @json_filename = 'google_drive_list.json'
    end

    def drive_list(optional_params = {}, page_limiter = nil)
      request(
        service_class: Google::Apis::DriveV2::DriveService,
        method_name: 'list_files',
        method_args: optional_params,
        page_limiter: page_limiter
      )
    end

    def mock_request
      super.merge(uri_matching: 'https://www.googleapis.com/drive/v2/files')
    end
  end
end
