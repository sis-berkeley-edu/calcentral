describe CampusSolutions::Checklist do
  let(:user_id) { '12347' }
  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns a list of items' do
      expect(subject[:feed][:checkListItems]).to_not be_empty
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::Checklist.new(fake: true, user_id: user_id) }
    subject { proxy.get }
    it_should_behave_like 'a proxy that gets data'
    it 'returns specific mock data' do
      expect(subject[:feed][:checkListItems][0][:emplid]).to eq '9000006532'
      expect(subject[:feed][:checkListItems][0][:checkListDescr]).to eq 'Statement, Intent to Register'
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::Checklist.new(fake: false, user_id: user_id) }
    it_should_behave_like 'a proxy that gets data'
  end
end
