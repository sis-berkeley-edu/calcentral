module GoogleApps
  class UpdateTask < Proxy
    require 'google/apis/tasks_v1'

    def initialize(options = {})
      super options
      @json_filename='google_tasks_update_successful.json'
    end

    def mock_request
      super.merge(method: :put,
        uri_matching: 'https://www.googleapis.com/tasks/v1/lists/MDkwMzQyMTI0OTE3NTY4OTU0MzY6NzAzMjk1MTk3OjA/tasks/MDkwMzQyMTI0OTE3NTY4OTU0MzY6NzAzMjk1MTk3OjEzODE3NzMzNzg')
    end

    def update_task(task_object, opts = {})
      opts.reverse_merge!(:task_list_id => '@default')
      request(
        service_class: Google::Apis::TasksV1::TasksService,
        method_name: 'update_task',
        method_args: [opts[:task_list_id], task_object.id, task_object]
      ).first
    end

  end
end
