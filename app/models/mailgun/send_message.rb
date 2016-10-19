module Mailgun
  class SendMessage < Proxy
    include ResponseWrapper

    def post(message_opts)
      handling_exceptions(request_url) do
        response = request({
          method: :post,
          body: message_opts
        })
        if response.code == 200
          {
            statusCode: 200,
            sending: true
          }
        else
          raise Errors::ProxyError.new("Error sending message: #{message_opts}")
        end
      end
    end

    private

    def mock_json
      read_file('fixtures', 'json', 'mailgun_send_message.json')
    end

    def mock_request
      super.merge(method: :post)
    end

    def request_path
      'messages'
    end
  end
end
