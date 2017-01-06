module Webcast
  class CourseMedia

    def self.id_per_ccn(year, term, ccn)
      # Allow lookups by either term_cd or term name
      term = term.to_s.strip
      term_cd = Berkeley::TermCodes.names[term.downcase]
      "#{year}-#{term_cd || term.upcase}-#{ccn}"
    end

    def initialize(year, term, ccn_list, options = {})
      @year = year
      @term = term
      @ccn_list = ccn_list
      @options = options
    end

    # Replaces '_slash_' with '/' since front-end encodes slashes. See CLC-4279.
    # We can remove this once Apache is updated and allows 'AllowEncodedSlashes NoDecode'
    def decode_slash(string)
      string.gsub('_slash_', '/')
    end

    def get_feed
      return {} unless Settings.features.videos
      media_hash = get_media_hash
      error_message = media_hash[:proxyErrorMessage]
      unless error_message.blank? && media_hash[:body].blank?
        return {
          :proxyErrorMessage => error_message || media_hash[:body]
        }
      end
      media_per_ccn = {}
      @ccn_list.each do |ccn|
        data = media_hash[ccn]
        if data
          media_per_ccn[ccn] = get_videos_as_json data
          media_per_ccn[ccn][:youTubePlaylist] = data[:youtube_playlist]
        end
      end
      media_per_ccn
    end

    def get_media_hash
      media_hash = {}
      all_media = Webcast::Recordings.new(@options).get
      if all_media && all_media[:courses]
        @ccn_list.each do |ccn|
          key = Webcast::CourseMedia.id_per_ccn(@year, @term, ccn)
          media = all_media[:courses][key]
          media_hash[ccn] = media unless media.nil?
        end
      end
      media_hash
    end

    def get_videos_as_json(playlist)
      if playlist[:recordings].blank?
        {
          :videos => []
        }
      else
        {
          :videos => playlist[:recordings].reverse
        }
      end
    end

  end
end
