

describe ENF::Message do
  it "handles the example message perfectly" do
    message = JMSMessageFactory.new('sis:student:messages', {
      student: {
        StudentId: 17154428
      }
    })

    subject = described_class.new(message.to_h)

    expect(subject.student_uid).to eq(17154428)
    expect(subject.topic).to eq('sis:student:messages')
  end
end
