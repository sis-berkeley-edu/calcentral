module GoogleApps
  class SheetsManager < DriveManager

    # Wrapper to avoid extra copies of large CSV tables.
    class CsvAsUpdates
      def initialize(csv)
        @csv = csv
      end
      def each(&block)
        row = 1
        @csv.each do |row_values|
          col = 1
          row_values.each do |value|
            yield [row, col], value
            col += 1
          end
          row += 1
        end
      end
    end

    def initialize(app_id, uid, opts={})
      super(app_id, uid, opts)
      auth = get_google_api.authorization
      # See https://github.com/gimite/google-drive-ruby
      @session = GoogleDrive::Session.login_with_oauth auth.access_token
    end

    def export_csv(file)
      csv_export_uri = if file.respond_to? :csv_export_url
                     file.csv_export_url
                   elsif file.exportLinks && file.exportLinks['text/csv']
                     file.exportLinks['text/csv']
                   end
      raise Errors::ProxyError, "No CSV export path found for file ID: #{file.id}" unless csv_export_uri
      result = @session.execute!(uri: csv_export_uri)
      log_response result
      raise Errors::ProxyError, "export_csv failed with file.id=#{file.id}. Error: #{result.data['error']}" if result.error?
      result.body
    end

    def spreadsheet_by_id(id)
      result = @session.execute!(:api_method => @session.drive.files.get, :parameters => { :fileId => id })
      log_response result
      case result.status
        when 200
          file = @session.wrap_api_file result.data
          raise Errors::ProxyError, "File is not a Google spreadsheet. Id: #{id}" unless file.is_a? GoogleDrive::Spreadsheet
        when 404
          logger.debug "No Google spreadsheet found with id = #{id}"
          file = nil
        else
          raise Errors::ProxyError, "spreadsheet_by_id failed with id=#{id}. Error: #{result.data['error']}"
      end
      file
    rescue Google::APIClient::TransmissionError => e
      log_transmission_error(e, "spreadsheet_by_id failed with id=#{id}")
      nil
    end

    def spreadsheets_by_title(title, opts={})
      query = "title='#{escape title}' and trashed=false"
      query.concat " and '#{opts[:parent_id]}' in parents" if opts.has_key? :parent_id
      spreadsheets = @session.spreadsheets(:q => query)
      logger.debug "No spreadsheets found. Query: #{query}" if spreadsheets.nil? || spreadsheets.none?
      spreadsheets
    rescue Google::APIClient::TransmissionError => e
      log_transmission_error(e, "spreadsheets_by_title failed with query: #{query}")
      nil
    end

    # An alternative implementation of GoogleDrive::Spreadsheet#save without the expensive XML parsing.
    def update_worksheet(worksheet, updates)
      raise Errors::ProxyError, "File #{worksheet.id} is not a Google Sheets worksheet" unless worksheet.is_a? GoogleDrive::Worksheet

      cells_feed_url = CGI.escapeHTML worksheet.cells_feed_url.to_s
      cells_feed_url_base = cells_feed_url.gsub(/\/private\/full\Z/, '')
      xml = <<-EOS
            <feed xmlns="http://www.w3.org/2005/Atom"
                  xmlns:batch="http://schemas.google.com/gdata/batch"
                  xmlns:gs="http://schemas.google.com/spreadsheets/2006">
              <id>#{cells_feed_url}</id>
      EOS

      updates.each do |coordinates, value|
        row, col = coordinates
        safe_value = value ? CGI.escapeHTML(value).gsub("\n", '&#x0a;') : nil
        xml << <<-EOS
              <entry>
                <batch:id>#{row},#{col}</batch:id>
                <batch:operation type="update"/>
                <id>#{cells_feed_url_base}/R#{row}C#{col}</id>
                <link rel="edit" type="application/atom+xml" href="#{cells_feed_url}/R#{row}C#{col}"/>
                <gs:cell row="#{row}" col="#{col}" inputValue="#{safe_value}"/>
              </entry>
        EOS
      end

      xml << <<-EOS
            </feed>
      EOS

      batch_url = "#{cells_feed_url}/batch"

      begin
        result = @session.execute!(
          http_method: :post,
          uri: batch_url,
          body: xml,
          headers: {
            'Content-Type' => 'application/atom+xml;charset=utf-8',
            'If-Match' => '*'
          }
        )
        log_response result
        raise Errors::ProxyError, "update_worksheet failed at URL #{batch_url}. Error: #{result.data['error']}" if result.error?
        raise Errors::ProxyError, "update_worksheet failed at URL #{batch_url}. Error: interrupted" if result.body.include? 'batch:interrupted'
        result.body
      rescue Google::APIClient::TransmissionError => e
        log_transmission_error(e, "update_worksheet failed failed at URL #{batch_url}")
        raise e
      end
    end

    def upload_to_spreadsheet(sheets_doc_title, path_or_io, parent_id, worksheet_title = nil)
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      media = Google::APIClient::UploadIO.new(path_or_io, 'text/csv')
      metadata = { :title => sheets_doc_title }
      file = drive_api.files.insert.request_schema.new metadata
      file.parents = [{ :id => parent_id }]
      result = @session.execute!(
        :api_method => drive_api.files.insert,
        :body_object => file,
        :media => media,
        :parameters => { :uploadType => 'multipart', :convert => true })
      log_response result
      raise Errors::ProxyError, "upload failed with title=#{sheets_doc_title}. Error: #{result.data['error']}" if result.error?
      sheets_doc = @session.wrap_api_file result.data
      if worksheet_title.present?
        primary_worksheet = sheets_doc.worksheets.first
        primary_worksheet.title = worksheet_title
        primary_worksheet.save
      end
      sheets_doc
    rescue Google::APIClient::TransmissionError => e
      log_transmission_error(e, "upload_to_spreadsheet failed with: #{[sheets_doc_title, path_or_io, parent_id].to_s}")
      raise e
    end

    def upload_csv_to_worksheet(sheets_doc, worksheet_title, csv)
      worksheet = sheets_doc.add_worksheet(worksheet_title, csv.length, csv.first.length)
      update_worksheet(worksheet, CsvAsUpdates.new(csv))
      worksheet.save
      worksheet
    end

    private

    def log_transmission_error(e, message_prefix)
      # Log error message and Google::APIClient::Result body
      logger.error "#{message_prefix}\n  Exception: #{e}\n  Google error_message: #{e.result.error_message}\n  Google response.data: #{e.result.body}\n"
    end

  end
end
