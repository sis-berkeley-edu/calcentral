describe CampusSolutions::AdvisorStudentRelationship do
  let(:user_id) { '12345' }
  subject { CampusSolutions::AdvisorStudentRelationship.new(user_id: user_id) }
  before do
    allow(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: user_id).and_return(
      double(lookup_campus_solutions_id: user_id))
  end

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:ucAaStudentAdvisor]).to be
      expect(subject[:feed][:ucAaStudentAdvisor][:studentAdvisor][0][:assignedAdvisorType]).to be
      expect(subject[:feed][:ucAaStudentAdvisor][:studentAdvisor][0][:assignedAdvisorProgram]).to be
      expect(subject[:feed][:ucAaStudentAdvisor][:studentAdvisor][0][:assignedAdvisorName]).to be
      expect(subject[:feed][:ucAaStudentAdvisor][:studentAdvisor][0][:assignedAdvisorEmail]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::AdvisorStudentRelationship.new(fake: true, user_id: user_id) }
    it_should_behave_like 'a proxy that gets data'
    subject { proxy.get }
    it 'should get specific mock data' do
      expect(subject[:feed][:ucAaStudentAdvisor][:studentAdvisor][0][:assignedAdvisorType]).to eq 'College Advisor'
      expect(subject[:feed][:ucAaStudentAdvisor][:studentAdvisor][0][:assignedAdvisorProgram]).to eq 'Undergrad Chemistry'
      expect(subject[:feed][:ucAaStudentAdvisor][:studentAdvisor][0][:assignedAdvisorName]).to eq 'Jane Doe'
      expect(subject[:feed][:ucAaStudentAdvisor][:studentAdvisor][0][:assignedAdvisorEmail]).to eq 'janed@example.com'
    end
  end
end
