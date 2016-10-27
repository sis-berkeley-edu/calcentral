describe MailingLists::OutgoingMessage do

  let(:list) do
    allow_any_instance_of(Canvas::Course).to receive(:course).and_return({body: {'name' => 'Design Analysis of Nuclear Reactors'}})
    MailingLists::MailgunList.create!(
      canvas_site_id: random_id,
      list_name: 'design_analysis_of_nuclear_reactors-sp17'
    )
  end

  let(:member) { list.members.find_by(can_send: true) }

  let(:message_opts) do
    {
      id: '<DLOAsW7ZwDP1yvQOabwgZ1AvXNGoGpJgRoV4HoVq9tjQKyD1f1w@mail.gmail.com>',
      from: 'Montgomery Burns <monty@berkeley.edu>',
      subject: 'A message of teaching and learning',
      body: {
        html: '<html><body>Instructional content goes here.<br><br><br>Montgomery Burns<br>Programming and Design Group<br>Educational Technology Services, UC Berkeley</body></html>',
        plain: "Instructional content goes here.\r\n\r\n\r\nMontgomery Burns\r\nProgramming and Design Group\r\nEducational Technology Services, UC Berkeley",
      },
      attachments: {}
    }
  end

  subject { described_class.new(list, member, message_opts) }

  context 'a list with two members' do
    before do
      MailingLists::Member.create!(
        email_address: 'monty@berkeley.edu',
        first_name: 'Montgomery',
        last_name: 'Burns',
        can_send: true,
        mailing_list_id: list.id
      )
      MailingLists::Member.create!(
        email_address: 'smithers@berkeley.edu',
        first_name: 'Waylon',
        last_name: 'Smithers',
        can_send: false,
        mailing_list_id: list.id
      )
    end

    shared_examples 'proper forwarding' do
      it 'makes a proxy request and reports success' do
        expect_any_instance_of(Mailgun::SendMessage).to receive(:post).with(request_matcher).and_return(
          response: {sending: true}
        )
        expect(subject.send_message[:response][:sending]).to be_truthy
      end
    end

    let(:request_matcher) do
      satisfy do |params|
        expect(params['Message-Id']).to eq '<DLOAsW7ZwDP1yvQOabwgZ1AvXNGoGpJgRoV4HoVq9tjQKyD1f1w@mail.gmail.com>'
        expect(params['from']).to eq '"Montgomery Burns (Design Analysis of Nuclear Reactors)" <no-reply@bcourses-mail.berkeley.edu>'
        expect(params['to']).to match_array %w(monty@berkeley.edu smithers@berkeley.edu)
        expect(params['subject']).to eq 'A message of teaching and learning'
        expect(params['h:Reply-To']).to eq 'Montgomery Burns <monty@berkeley.edu>'
        expect(JSON.parse params['recipient-variables']).to eq({'monty@berkeley.edu' => {}, 'smithers@berkeley.edu' => {}})
        expect(params['html']).to eq message_opts[:body][:html]
        expect(params['text']).to eq message_opts[:body][:plain]
      end
    end

    context 'a straightforward message' do
      include_examples 'proper forwarding'
    end

    context 'a message with blank body' do
      before do
        message_opts[:body][:html] = ''
        message_opts[:body][:plain] = ''
      end
      context 'expecting space padding' do
        let(:request_matcher) do
          satisfy do |params|
            expect(params['text']).to eq ' '
          end
        end
        include_examples 'proper forwarding'
      end
    end

    context 'a message with attachments' do
      before do
        message_opts[:attachments] = {
          count: 2,
          data: {
            'attachment-1' => ActionDispatch::Http::UploadedFile.new(
              filename: 'sample_student_72x96.jpg',
              tempfile: File.new(Rails.root.join 'public', 'dummy', 'images', 'sample_student_72x96.jpg'),
              type: 'image/jpg'
            ),
            'attachment-2' => ActionDispatch::Http::UploadedFile.new(
              filename: 'academic_dates.json',
              tempfile: File.new(Rails.root.join 'public', 'dummy', 'json', 'academic_dates.json'),
              type: 'application/json'
            )
          }
        }
      end
      context 'expecting multipart upload' do
        let(:request_matcher) do
          satisfy do |params|
            expect(params['attachment'].count).to eq 2
            expect(params['attachment'][0].content_type).to eq 'image/jpg'
            expect(params['attachment'][0].io.size).to be > 0
            expect(params['attachment'][0].local_path).to eq "#{Rails.root}/public/dummy/images/sample_student_72x96.jpg"
            expect(params['attachment'][0].original_filename).to eq 'sample_student_72x96.jpg'
            expect(params['attachment'][1].content_type).to eq 'application/json'
            expect(params['attachment'][1].io.size).to be > 0
            expect(params['attachment'][1].local_path).to eq "#{Rails.root}/public/dummy/json/academic_dates.json"
            expect(params['attachment'][1].original_filename).to eq 'academic_dates.json'
          end
        end
        include_examples 'proper forwarding'
      end
    end

    context 'a message with inline attachments' do
      before do
        message_opts[:attachments] = {
          count: 1,
          cid_map: {
            'EC2CE1CA-4686-4412-88C7-EC9A2176D97F' => 'attachment-1'
          },
          data: {
            'attachment-1' => ActionDispatch::Http::UploadedFile.new(
              filename: 'sample_student_72x96.jpg',
              tempfile: File.new(Rails.root.join 'public', 'dummy', 'images', 'sample_student_72x96.jpg'),
              type: 'image/jpg'
            )
          }
        }
        message_opts[:body][:html] = '<html><body>Keep this man away from the reactor: <img src="cid:EC2CE1CA-4686-4412-88C7-EC9A2176D97F"><br><br></body></html>'
      end
      context 'expecting multipart upload with inline references' do
        let(:request_matcher) do
          satisfy do |params|
            expect(params['inline'].count).to eq 1
            expect(params['inline'][0].original_filename).to eq 'sample_student_72x96.jpg'
            expect(params['html']).to eq '<html><body>Keep this man away from the reactor: <img src="cid:sample_student_72x96.jpg"><br><br></body></html>'
          end
        end
        include_examples 'proper forwarding'
      end
    end
  end

  context 'a list with one thousand and eleven members' do
    before do
      inserts = 1010.times.map { |i| "(#{list.id}, 'clone#{i}@berkeley.edu', 'Number #{i}', 'Clone', 'f')" }
      inserts << "(#{list.id}, 'monty@berkeley.edu', 'Montgomery', 'Burns', 't')"
      inserts.each_slice(250) do |insert_slice|
        sql = "INSERT INTO canvas_site_mailing_list_members (mailing_list_id, email_address, first_name, last_name, can_send) VALUES #{insert_slice.join(', ')}"
        ActiveRecord::Base.connection.execute sql
      end
    end

    let(:proxy_1) { Mailgun::SendMessage.new }
    let(:proxy_2) { Mailgun::SendMessage.new }

    def recipient_count(num)
      satisfy do |params|
        expect(params['to']).to have(num).items
        expect(JSON.parse(params['recipient-variables']).keys).to have(num).items
      end
    end

    it 'should batch requests' do
      expect(Mailgun::SendMessage).to receive(:new).exactly(2).times.and_return(proxy_1, proxy_2)
      expect(proxy_1).to receive(:post).with(recipient_count 1000).and_return(response: {sending: true})
      expect(proxy_2).to receive(:post).with(recipient_count 11).and_return(response: {sending: true})
      expect(subject.send_message[:response][:sending]).to be_truthy
    end

    it 'should abort on failed request' do
      expect(Mailgun::SendMessage).to receive(:new).exactly(1).times.and_return proxy_1
      expect(proxy_1).to receive(:post).with(recipient_count 1000).and_return(response: nil, exception: 'A confounding error')
      expect(subject.send_message[:response]).to be_falsey
    end
  end
end
