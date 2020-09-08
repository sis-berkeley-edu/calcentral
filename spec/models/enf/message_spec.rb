require_relative "./jms_message_factory"

describe ENF::Message do
  let(:campus_solutions_id) { 11111 }
  let(:uid) { 99999 }

  subject { described_class.new(message.to_h) }

  describe "studentId format" do
    let(:message) {
      JMSMessageFactory.new('sis:student:messages', {
        student: {
          StudentId: campus_solutions_id
        }
      })
    }

    it "extracts the topic from the JMS message" do
      expect(subject.topic).to eq('sis:student:messages')
    end

    it "looks up the UID from the Campus Solutions ID" do
      current_user = double(User::Current)
      expect(current_user).to receive(:uid).and_return(uid)
      expect(User::Current).to receive(:from_campus_solutions_id).with(campus_solutions_id).and_return(current_user)

      expect(subject.student_uids).to eq([99999])
    end
  end

  describe "batch format" do
    describe "with a single Campus Solutions ID" do
      let(:message) {
        JMSMessageFactory.new('sis:student:messages', {
          students: {
            id: campus_solutions_id
          }
        })
      }

      it "looks up the UID from the Campus Solutions ID" do
        current_user = double(User::Current)
        expect(current_user).to receive(:uid).and_return(uid)
        expect(User::Current).to receive(:from_campus_solutions_id).with(campus_solutions_id).and_return(current_user)

        expect(subject.student_uids).to eq([99999])
      end
    end

    describe "with multiple Campus Solutions IDs" do
      let(:campus_solutions_id_one) { 11111 }
      let(:campus_solutions_id_two) { 22222 }

      let(:message) {
        JMSMessageFactory.new('sis:student:messages', {
          students: {
            id: [campus_solutions_id_one, campus_solutions_id_two]
          }
        })
      }

      it "looks up the UIDs from the Campus Solutions IDs" do
        user_one = double(User::Current)
        expect(user_one).to receive(:uid).and_return(99999)
        user_two = double(User::Current)
        expect(user_two).to receive(:uid).and_return(88888)

        expect(User::Current).to receive(:from_campus_solutions_id).with(campus_solutions_id_one).and_return(user_one)
        expect(User::Current).to receive(:from_campus_solutions_id).with(campus_solutions_id_two).and_return(user_two)

        expect(subject.student_uids).to eq([99999, 88888])
      end
    end
  end
end
