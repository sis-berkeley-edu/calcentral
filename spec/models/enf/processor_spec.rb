require_relative './jms_message_factory'

describe ENF::Processor do
  class FakeStudentIDHandler
    def self.call(message)
      message.student_id
    end
  end

  subject { described_class.instance }
  after(:each) { subject.reset }
  let(:messages_topic) { 'sis:student:messages' }
  let(:checklist_topic) { 'sis:student:checklist' }
  let(:student_id) { 1234 }

  let(:message_payload) {
    {
      student: {
        StudentId: student_id
      }
    }
  }

  it "dispatches incoming JMS messages to the registered handler" do
    subject.register(messages_topic, FakeStudentIDHandler)
    expect_any_instance_of(ENF::Message).to receive(:student_id).and_return(student_id)

    subject.handle(JMSMessageFactory.new(messages_topic, message_payload).to_h)
  end

  it "doesn't dispatch messages to other topics" do
    described_class.instance.register(messages_topic, FakeStudentIDHandler)
    expect_any_instance_of(ENF::Message).not_to receive(:student_id)

    subject.handle(JMSMessageFactory.new(checklist_topic, message_payload).to_h)
  end
end
