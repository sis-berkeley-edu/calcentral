module GoogleApps
  class TasksList < Proxy
    require 'google/apis/tasks_v1'

    def initialize(options = {})
      super options
      @json_filename='google_tasks_list.json'
    end

    def mock_request
      super.merge(method: :get,
                  uri_matching: 'https://www.googleapis.com/tasks/v1/lists/@default/tasks')
    end

    def tasks_list(opts={})
      opts.reverse_merge!(:tasklist => '@default', :max_results => 100)
      tasklist = opts.delete(:tasklist)
      request(
        service_class: Google::Apis::TasksV1::TasksService,
        method_name: 'list_tasks',
        method_args: [tasklist, opts]
      ).first
    end

  end
end
