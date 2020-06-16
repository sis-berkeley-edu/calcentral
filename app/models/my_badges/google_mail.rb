module MyBadges
  class GoogleMail
    include MyBadges::BadgesModule, DatedFeed, ClassLogger

    def initialize(uid)
      @uid = uid
      @max_entries = 25
    end

    def fetch_counts(params = {})
      @google_mail ||= User::Oauth2Data.get_google_email(@uid)
      @rewrite_url ||= !(Mail::Address.new(@google_mail).domain =~ /berkeley.edu/).nil?
      internal_fetch_counts params
    end

    private

    def internal_fetch_counts(params = {})
      google_proxy = GoogleApps::MailList.new(user_id: @uid)
      google_mail_results = google_proxy.mail_unread
      parse_feed google_mail_results
    end

    def parse_feed(google_mail_results)
      count = 0
      items = []
      begin
        if google_mail_results.present?
          feed = FeedWrapper.new MultiXml.parse(google_mail_results)
          count = feed['feed']['fullcount'].to_i
          items = feed['feed']['entry'].as_collection.each_with_index.map do |entry, index|
            break if index == @max_entries
            {
              editor: entry['author']['name'].to_text,
              link: 'http://bmail.berkeley.edu/',
              modifiedTime: format_date(entry['modified'].to_date),
              summary: entry['summary'].to_text,
              title: entry['title'].to_text
            }
          end
        end
      rescue => e
        logger.fatal "Error parsing GoogleApps::MailList response: #{e.message}\n#{e.backtrace.join "\n\t"}"
      end
      {
        count: count,
        items: items
      }
    end

  end
end
