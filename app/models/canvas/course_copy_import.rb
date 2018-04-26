module Canvas
  class CourseCopyImport < Proxy

    def initialize(options = {})
      super(options)
      @canvas_course_id = options[:canvas_course_id]
    end

    def import_course_template(template_id)
      wrapped_post request_path, {
        'migration_type' => 'course_copy_importer',
        'settings[source_course_id]' => template_id
      }
    end

    private

    def request_path
      "courses/#{@canvas_course_id}/content_migrations"
    end

    def mock_interactions
      on_request(uri_matching: "#{api_root}/#{request_path}", method: :post).
        respond_with_file('fixtures', 'json', 'canvas_course_copy_import.json')
      on_request(uri_matching: "#{api_root}/#{request_path}", method: :put)
        .respond_with_file('fixtures', 'json', 'canvas_reset_authorization_config.json')

    end

  end
end
