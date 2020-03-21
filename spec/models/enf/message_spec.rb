describe ENF::Message do
  let(:message) {
    JMSMessageFactory.new('sis:student:messages', {
      student: {
        StudentId: campus_solutions_id
      }
    })
  }

  let(:campus_solutions_id) { 11111 }
  let(:uid) { 99999 }

  subject { described_class.new(message.to_h) }

  it "extracts the topic from the JMS message" do
    expect(subject.topic).to eq('sis:student:messages')
  end

  it "looks up the UID from the Campus Solutions ID" do
    current_user = double(User::Current)
    expect(current_user).to receive(:uid).and_return(uid)
    expect(User::Current).to receive(:from_campus_solutions_id).with(campus_solutions_id).and_return(current_user)

    expect(subject.student_uid).to eq(99999)
  end
end
