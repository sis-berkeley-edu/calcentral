describe CampusSolutions::DegreeProgress::GraduateMilestones do

  let(:user_id) { '12345' }
  let(:proxy) { described_class.new(fake: true, user_id: user_id) }

  describe '#get' do
    subject { proxy.get }

    it_behaves_like 'a simple proxy that returns errors'

    it_behaves_like 'a proxy that got data successfully'
  end
end
