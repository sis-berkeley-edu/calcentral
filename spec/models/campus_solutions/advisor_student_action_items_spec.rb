describe CampusSolutions::AdvisorStudentActionItems do
  let(:user_id) { '12345' }
  before do
    allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: user_id).and_return(
      double(lookup_campus_solutions_id: user_id))
  end

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:ucAaActionItems][:actionItems]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::AdvisorStudentActionItems.new(fake: true, user_id: user_id) }
    it_should_behave_like 'a proxy that gets data'
    subject { proxy.get }
    it 'should get specific mock data' do
      expect(subject[:feed][:ucAaActionItems][:actionItems][0][:actionItemView]).to eq 'Complete'
      expect(subject[:feed][:ucAaActionItems][:actionItems][0][:actionItemTitle]).to eq 'Action Item test'
      expect(subject[:feed][:ucAaActionItems][:actionItems][0][:actionItemDueDate]).to eq '2016-07-25'
      expect(subject[:feed][:ucAaActionItems][:actionItems][0][:actionItemStatus]).to eq 'Incomplete'
      expect(subject[:feed][:ucAaActionItems][:actionItems][0][:actionItemAssignedDate]).to eq '2016-07-22'
      expect(subject[:feed][:ucAaActionItems][:actionItems][0][:actionItemAssignedAdvisor]).to eq nil
      expect(subject[:feed][:ucAaActionItems][:actionItems][0][:actionItemDescription]).to eq 'Testing 123'
    end
  end
end
