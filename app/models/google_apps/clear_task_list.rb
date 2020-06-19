module GoogleApps
  class ClearTaskList < Proxy
    require 'google/apis/tasks_v1'

    def mock_request
      super.merge(method: :post,
                  uri_matching: 'https://www.googleapis.com/tasks/v1/lists/@default/clear')
    end

    def mock_response
      super.merge({status: 204})
    end

    def mock_json
      '{}'
    end

    def clear_task_list(task_list_id = nil, opts={})
      task_list_id ||= '@default'
      request(
        service_class: Google::Apis::TasksV1::TasksService,
        method_name: 'clear_task',
        method_args: [task_list_id, opts],
      ).first
    end

  end
end
