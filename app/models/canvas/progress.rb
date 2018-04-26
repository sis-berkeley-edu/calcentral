module Canvas
  class Progress < Proxy

    def initialize(options = {})
      super(options)
      @progress_id = options[:progress_id]
    end

    def get_progress()
      wrapped_get request_path
    end

    private

    def request_path
      "progress/#{@progress_id}"
    end

    def mock_json
      read_file('fixtures', 'json', 'canvas_progress.json')
    end

  end
end
