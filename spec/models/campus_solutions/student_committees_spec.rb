describe CampusSolutions::StudentCommittees do

  let(:user_id) { random_id }
  let(:user_cs_id) { random_id }

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the committees feature flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:ucSrStudentCommittee]).to be
    end
  end

  context 'mock proxy' do
    before do
      allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: user_id).and_return(
        double(lookup_campus_solutions_id: user_cs_id))
    end
    let(:proxy) { CampusSolutions::StudentCommittees.new(fake: true, user_id: user_id) }
    subject { proxy.get }
    it_should_behave_like 'a proxy that gets data'
    it 'should get specific mock data' do
      expect(subject[:feed][:ucSrStudentCommittee][:emplid]).to eq '123456789'
    end
  end

end
