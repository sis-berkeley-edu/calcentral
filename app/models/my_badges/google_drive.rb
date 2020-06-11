module MyBadges
  class GoogleDrive
    include MyBadges::BadgesModule, DatedFeed, ClassLogger
    include Cache::UserCacheExpiry

    def initialize(uid)
      @uid = uid
      @now_time = Time.zone.now
      @one_month_ago = @now_time.advance(:months => -1)
      # Puts a max page-request limit on the drive listing to prevent an excessive number of pages from coming back.
      @page_limiter = 4
      # Limiter on the maximum number of changed drive files to be concerned about.
      @count_limiter = 25
    end

    def fetch_counts
      self.class.fetch_from_cache(@uid) do
        internal_fetch_counts
      end
    end

    private

    def internal_fetch_counts
      # Limit results with some file.list query params.
      # TODO: change this to factor in the last change timestamp the user's seen
      last_viewed_change ||= @one_month_ago.iso8601
      query = "modifiedDate >= '#{last_viewed_change}' and trashed = false"

      google_proxy = GoogleApps::DriveList.new(user_id: @uid)
      google_drive_results = google_proxy.drive_list(optional_params={q: query}, page_limiter=@page_limiter)

      response = {
        count: 0,
        items: [],
      }
      processed_pages = 0
      google_drive_results.each_with_index do |response_page, index|
        logger.info "Processing page ##{index} of drive_list results"
        next unless response_page.present?
        response_page.items.each do |drive_file|
          begin
            if is_recent_message?(drive_file)
              if response[:count] < @count_limiter
                next unless !drive_file.title.blank?

                item = {
                  title: drive_file.title,
                  link: drive_file.alternate_link,
                  icon_url: drive_file.icon_link,
                  modifiedTime: format_date(drive_file.modified_date.to_datetime),
                  editor: drive_file.last_modifying_user.display_name,
                  changeState: handle_change_state(drive_file),
                }
                response[:items] << item
              end
              response[:count] += 1
            end
          rescue => e
            logger.warn "#{e}: #{e.message}: file id: #{drive_file.id}, #{drive_file.title}, created: #{drive_file.created_date}, modified: #{drive_file.modified_date}"
            next
          end
        end
        processed_pages += 1
      end

      # Since we're likely looking at partial google drive file list response, add some approximation indication.
      if processed_pages == @page_limiter
        response[:count] = response[:count].to_s + "+"
      end
      response
    end

    def handle_change_state(file)
      if file.created_date == file.modified_date
        return "new"
      else
        return "modified"
      end
    end

    def is_recent_message?(file)
      return false unless file.created_date && file.modified_date
      begin
        date_fields = [file.created_date.to_s, file.modified_date.to_s]
        date_fields.map! {|x| Time.zone.parse(x).to_i }
      rescue => e
        logger.warn "Problems parsing created_date: #{file.created_date} modified_time: #{file.modified_date}"
        return false
      end
      @one_month_ago.to_i <= date_fields.max
    end
  end
end
