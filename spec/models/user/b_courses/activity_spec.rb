describe User::BCourses::Activity do
  describe "#processed_type" do
    it 'Converts known types from bCourses to notification type' do
      examples = [
        ['Announcement', 'announcement'],
        ['Collaboration', 'discussion'],
        ['Conversation', 'discussion'],
        ['DiscussionTopic', 'discussion'],
        ['CollectionItem', 'assignment'],
        ['Message', 'assignment'],
        ['Submission', 'gradePosting'],
        ['WebConference', 'webconference'],
      ]

      examples.each do |example|
        type, expected = example

        subject = described_class.new({ type: type })
        expect(subject.processed_type).to eq expected
      end
    end

    it 'Converts unknown bCourses types to "assignment"' do
      subject = described_class.new({ type: "unknown" })
      expect(subject.processed_type).to eq "assignment"
    end
  end
end
