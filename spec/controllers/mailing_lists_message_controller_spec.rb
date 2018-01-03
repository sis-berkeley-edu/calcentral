describe MailingListsMessageController do
  let(:message_params) { JSON.parse File.read(Rails.root.join('fixtures', 'json', 'mailgun_incoming_message.json')) }
  let(:make_request) { post :relay, message_params }

  shared_examples 'verification failed' do
    it 'returns empty 401' do
      make_request
      expect(response.status).to eq 401
      expect(response.body).to be_blank
    end
  end

  context 'missing signature' do
    before do
      message_params.delete 'signature'
    end
    include_examples 'verification failed'
  end

  context 'invalid signature' do
    before do
      message_params['timestamp'] = Time.now.to_i.to_s
      message_params['signature'] = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest::SHA256.new,
        'wrong_api_key',
        message_params.values_at('timestamp', 'token').join
      )
    end
    include_examples 'verification failed'
  end

  context 'valid signature on expired timestamp' do
    before do
      message_params['timestamp'] = (Time.now.to_i - 3600).to_s
      message_params['signature'] = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest::SHA256.new,
        Settings.mailgun_proxy.api_key,
        message_params.values_at('timestamp', 'token').join
      )
    end
    include_examples 'verification failed'
  end

  context 'valid signature on current timestamp' do
    before do
      message_params['timestamp'] = Time.now.to_i.to_s
      message_params['signature'] = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest::SHA256.new,
        Settings.mailgun_proxy.api_key,
        message_params.values_at('timestamp', 'token').join
      )
      expect_any_instance_of(MailingLists::IncomingMessage).to receive(:relay).and_return true
    end

    it 'forwards to model and returns success' do
      expect(MailingLists::IncomingMessage).to receive(:new).with(hash_including(
        id: '<DLOAsW7ZwDP1yvQOabwgZ1AvXNGoGpJgRoV4HoVq9tjQKyD1f1w@mail.gmail.com>',
        from: 'Paul Kerschen <kerschen@berkeley.edu>',
        to: 'design_analysis_of_nuclear_reactors-sp17@bcourses-lists.berkeley.edu',
        subject: 'A message of teaching and learning',
        sender: 'kerschen@berkeley.edu',
        recipient: 'design_analysis_of_nuclear_reactors-sp17@bcourses-lists.berkeley.edu',
        attachments: {}
      )).and_call_original

      make_request
      expect(response.status).to eq 200
      expect(response.body).to include 'success'
    end

    it 'forbids repeated signatures' do
      post :relay, message_params
      expect(response.status).to eq 200

      post :relay, message_params
      expect(response.status).to eq 401
    end

    context 'message with attachments' do
      let(:attachment_1) do
        Rack::Test::UploadedFile.new(
          content = File.new(Rails.root.join 'public', 'dummy', 'images', 'sample_student_72x96.jpg'),
          content_type = 'image/jpg',
          binary = false
        )
      end
      let(:attachment_2) do
        Rack::Test::UploadedFile.new(
          content = File.new(Rails.root.join 'public', 'dummy', 'json', 'academic_dates.json'),
          content_type = 'application/json',
          binary = false
        )
      end
      before do
        message_params['attachment-1'] = attachment_1
        message_params['attachment-2'] = attachment_2
        message_params['attachment-count'] = '2'
        message_params['content-id-map'] = '{"<EC2CE1CA-4686-4412-88C7-EC9A2176D97F>": "attachment-1"}'
      end

      it 'handles attachments' do
        expect(MailingLists::IncomingMessage).to receive(:new).with(hash_including(
          attachments: {
            count: 2,
            cid_map: {
              'EC2CE1CA-4686-4412-88C7-EC9A2176D97F' => 'attachment-1'
            },
            data: {
              'attachment-1' => attachment_1,
              'attachment-2' => attachment_2
            }
          }
        )).and_call_original

        make_request
        expect(response.status).to eq 200
        expect(response.body).to include 'success'
      end
    end
  end
end
