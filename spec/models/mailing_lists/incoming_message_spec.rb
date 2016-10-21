describe MailingLists::IncomingMessage do

  let(:message_opts) do
    {
      id: '<DLOAsW7ZwDP1yvQOabwgZ1AvXNGoGpJgRoV4HoVq9tjQKyD1f1w@mail.gmail.com>',
        sender: sender,
        recipient: recipient,
        subject: 'A message of teaching and learning',
        body: {
        html: '<html><body>Instructional content goes here.<br><br><br>Paul Kerschen<br>Programming and Design Group<br>Educational Technology Services, UC Berkeley</body></html>',
        plain: "Instructional content goes here.\r\n\r\n\r\nPaul Kerschen\r\nProgramming and Design Group\r\nEducational Technology Services, UC Berkeley",
      },
        attachments: {
        count: 1,
        data: {
          1 => 'fake attachment'
        }
      }
    }
  end

  subject { described_class.new message_opts }

  let(:canvas_site_id) { random_id }
  before do
    MailingLists::MailgunList.create!(
      canvas_site_id: canvas_site_id,
      list_name: 'design_analysis_of_nuclear_reactors-sp17'
    )
  end
  let(:list) { MailingLists::MailgunList.find_by(canvas_site_id: canvas_site_id) }

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

  let(:bounce_matcher) do
    satisfy do |opts|
      expect(opts[:from]).to eq 'bCourses Mailing Lists <no-reply@bcourses-mail.berkeley.edu>'
      expect(opts[:to]).to eq sender
      expect(opts[:subject]).to eq 'Undeliverable mail'
      expect(opts[:text]).to include expected_bounce_message
    end
  end

  shared_examples 'proper bounce handling' do
    it 'bounces to sender and does not forward to list' do
      expect_any_instance_of(MailingLists::OutgoingMessage).not_to receive(:send_message)
      expect_any_instance_of(Mailgun::SendMessage).to receive(:post).with(bounce_matcher).and_return(
        response: {sending: true}
      )
      expect(subject.dispatch).to be_truthy
    end
  end

  shared_examples 'proxy failure handling' do
    before do
      allow_any_instance_of(Mailgun::SendMessage).to receive(:post).and_return(
        {response: {statusCode: 503}, exception: 'A confounding error'}
      )
    end
    it 'reports proxy failure' do
      expect(subject.dispatch).to be_falsey
    end
  end

  context 'nonexistent mailing list' do
    let(:sender) { 'A Spammer <spam_i_am@berkeley.edu>' }
    let(:recipient) { 'not_a_course-sp17@bcourses-mail.berkeley.edu' }
    let(:expected_bounce_message) { 'not_a_course-sp17@bcourses-mail.berkeley.edu was not found in our system.' }
    include_examples 'proper bounce handling'
    include_examples 'proxy failure handling'
  end

  context 'existent mailing list' do
    let(:recipient) { 'Nuclear Reactors <design_analysis_of_nuclear_reactors-sp17@bcourses-mail.berkeley.edu>' }
    context 'message from non-member' do
      let(:sender) { 'Disco Stu <discostu@berkeley.edu>' }
      let(:expected_bounce_message) { 'the mailing list design_analysis_of_nuclear_reactors-sp17@bcourses-mail.berkeley.edu did not recognize the email address discostu@berkeley.edu.' }
      include_examples 'proper bounce handling'
      include_examples 'proxy failure handling'
    end

    context 'message from member' do
      context 'member without sending privileges' do
        let(:sender) { 'Waylon Smithers <smithers@berkeley.edu>' }
        let(:expected_bounce_message) { 'the email address smithers@berkeley.edu is not authorized to send messages to the list design_analysis_of_nuclear_reactors-sp17@bcourses-mail.berkeley.edu.' }
        include_examples 'proper bounce handling'
        include_examples 'proxy failure handling'
      end

      context 'member with sending privileges' do
        let(:sender) { 'Montgomery Burns <monty@berkeley.edu>' }
        it 'forwards to list' do
          monty = list.members.find_by email_address: 'monty@berkeley.edu'
          expect(MailingLists::OutgoingMessage).to receive(:new).with(list, monty, message_opts)
           .and_return double(send_message: {response: {sending: true}})
          expect(subject.dispatch).to be_truthy
        end
        include_examples 'proxy failure handling'
      end
    end
  end

  context 'bad args on initialization' do
    let(:message_opts) { {arrant: :nonsense} }
    it 'reports failure' do
      expect(Rails.logger).to receive(:error).with /Could not dispatch/
      expect(subject.dispatch).to be_falsey
    end
  end
end
