module User
  module BCourses
    class Activity
      include HtmlSanitizer

      attr_accessor :dashboard_sites

      attr_accessor :id, :uid, :title, :created_at, :updated_at, :type,
        :html_url, :context_type, :course_id, :message, :score,
        :submission_comments, :classes

      def as_json(options={})
        {
          statusDate: max_date&.to_date,
          statusDateTime: max_date&.to_datetime,
          emitter: 'bCourses',
          id: "canvas_#{id}",
          source: source,
          sourceName: source,
          source_url: html_url,
          title: processed_title,
          description: summary,
          type: processed_type,
          url: html_url
        }
      end

      def initialize(attrs={})
        attrs.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def processed_title
        case type
        when 'Message'
          split_on_colon_or_dash(title).first
        when 'Conversation'
          title || 'New/Updated Conversation'
        else
          title
        end
      end

      def processed_type
        case type.downcase
        when 'announcement' then 'announcement'
        when 'collaboration', 'conversation', 'discussiontopic' then 'discussion'
        when 'collectionitem', 'message' then 'assignment'
        when 'submission' then 'gradePosting'
        when 'webconference' then 'webconference'
        else
          logger.warn "No match for entry type: #{type}"
          'assignment'
        end
      end

      def summary
        summary_message + summary_score
      end

      def summary_message
        message_body = sanitize_html(message || '').squish

        # Remove system-generated "Click here" strings, leaving instructor-added "Click here" strings intact
        [
          /Click here to view the assignment: http.*/,
          /You can view the submission here: http.*/
        ].each do |regex|
          if (rindex = message_body.rindex(regex))
            message_body.slice!(rindex..-1)
          end
        end

        if (type == 'Message') && (message_summary = split_on_colon_or_dash(title).last)
          "#{message_summary} - #{message_body.strip}"
        else
          message_body.strip
        end
      end

      def source
        if site
          course_codes || site[:source] || site[:name]
        else
          ::Canvas::Proxy::APP_NAME
        end
      end

      # Some assignments have been graded - append score and comments to summary
      def summary_score
        if score && assignment && assignment.points_possible
          score_message = " #{score} out of #{assignment.points_possible}"

          if submission_comments
            if submission_comments.length == 1
              score_message += " - #{submission_comments.first['body']}"
            elsif submission_comments.length > 1
              score_message += " - #{submission_comments.length} comments"
            end
          end

          score_message
        else
          ""
        end
      end

      def site_type
        context_type.downcase if context_type
      end

      def site
        if site_from_emitter && site_from_emitter[:siteType] == site_type
          site_from_emitter
        end
      end

      def has_max_date?
        max_date.present?
      end

      def has_processed_title?
        processed_title.present?
      end

      # returns nil if dates are in any way incompatible for max comparison
      # e.g., ArgumentError: comparison of Time with nil failed
      def max_date
        [created_at, updated_at].max
      rescue
        nil
      end

      private

      def site_from_emitter
        @site_from_emitter ||= classes_by_emitter[:canvas][send("#{site_type}_id").to_s]
      end

      def split_on_colon_or_dash(string)
        string.split(/ - |: /, 2)
      end

      def classes_by_emitter
        indexed = {
          campus: {},
          canvas: {}
        }

        dashboard_sites.each do |course|
          case course[:emitter]
          when 'Campus'
            course[:listings].each { |listing| indexed[:campus][listing[:id]] = listing }
          when ::Canvas::Proxy::APP_NAME
            indexed[:canvas][course[:id]] = course
          end
        end
        indexed
      end

      def course_codes
        return unless site[:courses] && classes
        course_listings = site[:courses].map { |course| classes[:campus][course[:id]] }.compact
        if course_listings.any?
          course_codes = course_listings.map { |listing| listing[:course_code] }
          course_codes.length == 1 ? course_codes.first : course_codes
        end
      end
    end
  end
end
