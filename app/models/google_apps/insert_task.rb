module GoogleApps
  class InsertTask < Proxy
    require 'google/apis/tasks_v1'

    def initialize(options = {})
      super options
      @json_filename='google_insert_task.json'
    end

    def mock_request
      super.merge(method: :post,
        uri_matching: 'https://www.googleapis.com/tasks/v1/lists/MDkwMzQyMTI0OTE3NTY4OTU0MzY6NzAzMjk1MTk3OjA/tasks')
    end

    def insert_task(task_object, opts={})
      opts.reverse_merge!(:task_list_id => '@default')
      request(
        service_class: Google::Apis::TasksV1::TasksService,
        method_name: 'insert_task',
        method_args: [opts[:task_list_id], task_object]
      ).first
    end

  end
end
