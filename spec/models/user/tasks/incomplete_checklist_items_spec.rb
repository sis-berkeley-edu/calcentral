describe User::Tasks::IncompleteChecklistItems do
  let(:fake_user) { User::Current.new('fake-uid') }

  describe "#all" do
    it "excludes ignored status codes" do
      mock_data_source = double()
      expect(mock_data_source).to receive(:incomplete_checklist_items).with('fake-uid').and_return([
        {
          title: 'Incomplete Checklist Item',
          status_code: User::Tasks::ChecklistItem::STATUS_INCOMPLETE
        },
        {
          title: 'An Ignored Checklist Item',
          status_code: User::Tasks::ChecklistItem::IGNORED_STATUS_CODES.first
        }
      ])

      subject = described_class.new(fake_user)
      subject.data_source = mock_data_source
      result = subject.all
      expect(result.collect(&:title)).to eq ['Incomplete Checklist Item']
    end
  end
end
