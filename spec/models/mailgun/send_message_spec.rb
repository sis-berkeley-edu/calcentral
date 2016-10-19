describe Mailgun::SendMessage do
  let(:proxy) { described_class.new(fake: true) }

  describe '#post' do
    subject do
      proxy.post(
        from: 'Hedy Lamarr (Frequency Hopping Fall 2016) <no-reply-789622452@bcourses-mail.berkeley.edu>',
        to: 'Paul Kerschen <kerschen@berkeley.edu>',
        :'h:Reply-To' => 'Hedy Lamarr <hlamarr@berkeley.edu>',
        subject: 'Assignment #1 Due Monday',
        text: 'Please have your spread-spectrum transmitters set up in the auditorium and ready for testing by 10 am Monday morning. I look forward to seeing your work! -HL'
      )
    end

    it_behaves_like 'a polite HTTP client'

    it 'reports success' do
      expect(subject[:response][:statusCode]).to eq 200
      expect(subject[:response][:sending]).to be_truthy
      expect(subject[:exception]).to be_falsey
    end

    context 'failure' do
      let(:status) { 500 }
      let(:body) { '{"message": "I would prefer not to send email."}' }
      before { proxy.set_response(status: status, body: body) }

      include_context 'expecting logs from server errors'

      it 'reports failure' do
        expect(subject[:response][:statusCode]).to eq 503
        expect(subject[:response][:sending]).to be_falsey
        expect(subject[:exception]).to be_truthy
      end
    end
  end
end
