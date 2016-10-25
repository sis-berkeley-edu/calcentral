describe MailingLists::OutgoingMessage do

  let(:list) do
    MailingLists::MailgunList.create!(
      canvas_site_id: random_id,
      list_name: 'design_analysis_of_nuclear_reactors-sp17'
    )
  end

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

  shared_examples 'proper forwarding' do
    it 'makes a proxy request and reports success' do
      expect_any_instance_of(Mailgun::SendMessage).to receive(:post).with(request_matcher).and_return(
        response: {sending: true}
      )
      expect(subject.send_message).to be_truthy
    end
  end

  let(:request_matcher) do
    satisfy do |params|
      expect(params).to include({
        'Message-Id' => '<DLOAsW7ZwDP1yvQOabwgZ1AvXNGoGpJgRoV4HoVq9tjQKyD1f1w@mail.gmail.com>',
        'from' => 'Montgomery Burns <no-reply@bcourses-mail.berkeley.edu>',
        'to' => %w(monty@berkeley.edu smithers@berkeley.edu),
        'subject' => 'A message of teaching and learning',
        'h:Reply-To' => 'Montgomery Burns <monty@berkeley.edu>',
        'html' => message_opts[:body][:html],
        'text' => message_opts[:body][:plain]
      })
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
          'attachment-1' => {
            'filename' => 'sample_student_72x96.jpg',
            'name' => 'attachment-1',
            'tempfile' => File.new(Rails.root.join 'public', 'dummy', 'images', 'sample_student_72x96.jpg'),
            'type' => 'image/jpg'
          },
          'attachment-2' => {
            'filename' => 'academic_dates.json',
            'name' => 'attachment-2',
            'tempfile' => File.new(Rails.root.join 'public', 'dummy', 'json', 'academic_dates.json'),
            'type' => 'application/json'
          }
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
          'attachment-1' => {
            'filename' => 'sample_student_72x96.jpg',
            'name' => 'attachment-1',
            'tempfile' => File.new(Rails.root.join 'public', 'dummy', 'images', 'sample_student_72x96.jpg'),
            'type' => 'image/jpg'
          }
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
