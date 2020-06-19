module GoogleApps
  class DeleteTask < Proxy
    require 'google/apis/tasks_v1'

    def mock_request
      super.merge(method: :delete,
                  uri_matching: 'https://www.googleapis.com/tasks/v1/lists/MDkwMzQyMTI0OTE3NTY4OTU0MzY6NzAzMjk1MTk3OjA/tasks/MDkwMzQyMTI0OTE3NTY4OTU0MzY6NzAzMjk1MTk3OjEzODE3NzMzNzg')
    end

    def mock_response
      super.merge({status: 204})
    end

    def mock_json
      '{}'
    end

    def delete_task(task_id, opts={})
      opts.reverse_merge!(:task_list_id => '@default')
      proxy_response = request(
        service_class: Google::Apis::TasksV1::TasksService,
        method_name: 'delete_task',
        method_args: [opts[:task_list_id], task_id],
      ).first
    end

  end
end
