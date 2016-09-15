describe CampusSolutions::FacultyCommittees do

  let(:user_id) { '10634814' }

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the committees feature flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:ucSrFacultyCommittee]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::FacultyCommittees.new(fake: true, user_id: user_id) }
    subject { proxy.get }
    it_should_behave_like 'a proxy that gets data'
    it 'should get specific mock data' do
      expect(subject[:feed][:ucSrFacultyCommittee][:emplid]).to eq '10113922'
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::FacultyCommittees.new(fake: false, user_id: user_id) }
    it_should_behave_like 'a proxy that gets data'
  end

end
