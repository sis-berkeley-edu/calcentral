module Canvas
  class CourseSettings < Proxy
    include ClassLogger

    DEFAULT_HOME_PAGE = 'feed'

    def initialize(options = {})
      super(options)
      @course_id = options[:course_id]
    end

    def settings(options = {})
      optional_cache(options, key: @course_id.to_s, default: true) do
        wrapped_get "#{request_path}/settings"
      end
    end

    def set_grading_scheme(grading_scheme_id = nil)
      # Oddly enough, the 'grading_standard_id' has to be updated via the Course API rather than Course Settings API
      # https://canvas.instructure.com/doc/api/courses.html#method.courses.update
      grading_scheme_id ||= @settings.default_grading_scheme_id.to_i
      wrapped_put request_path, {
        'course' => {
          'grading_standard_id' => grading_scheme_id
        }
      }
    end

    # WARNING: This is currently undocumented. Described at "https://community.canvaslms.com/thread/11645".
    def set_default_view(default_view)
      wrapped_put request_path, {
        'course' => {
          'default_view' => default_view
        }
      }
    end

    # If necessary, reset a site to use ETS's preferred default landing page.
    def fix_default_view(course_properties)
      if course_properties['default_view'] != DEFAULT_HOME_PAGE
        logger.info "Will change default view for site ID #{@course_id} from '#{course_properties['default_view']}' to '#{DEFAULT_HOME_PAGE}'"
        results = set_default_view DEFAULT_HOME_PAGE
        logger.error "Could not change default view for site ID #{@course_id}" if results[:statusCode] != 200
        results
      end
    end

    private

    def request_path
      "courses/#{@course_id}"
    end

    def mock_interactions
      on_request(uri_matching: "#{api_root}/#{request_path}", method: :get)
        .respond_with_file('fixtures', 'json', 'canvas_course_settings.json')

      on_request(uri_matching: "#{api_root}/#{request_path}", method: :put)
        .respond_with_file('fixtures', 'json', 'canvas_course_settings_set_grading_scheme.json')
    end

  end
end
