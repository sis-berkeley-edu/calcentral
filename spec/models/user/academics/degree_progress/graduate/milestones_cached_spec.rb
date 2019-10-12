describe User::Academics::DegreeProgress::Graduate::MilestonesCached do
  let(:uid) { random_id }
  let(:user) { User::Current.new(uid) }
  let(:grad_milestones_progresses) do
    ['Grad Milestone 1','Grad Milestone 2']
  end
  let(:grad_milestones_response) do
    {
      feed: {
        ucAaProgress: {
          progresses: grad_milestones_progresses
        }
      }
    }
  end
  let(:grad_milestones) do
    double({
      get: grad_milestones_response
    })
  end
  subject { described_class.new(user) }

  before { allow(CampusSolutions::DegreeProgress::GraduateMilestones).to receive(:new).with(user_id: uid).and_return(grad_milestones) }

  it 'returns uid as instance key' do
    expect(subject.instance_key).to eq uid
  end

  describe '#get_feed' do
    context 'when there is an error retreiveing milestones' do
      let(:grad_milestones_response) { {errored: true} }
      it 'returns empty array' do
        expect(subject.get_feed).to eq([])
      end
    end
    context 'when there is an error retreiveing milestones' do
      let(:grad_milestones_response) { {noStudentId: true} }
      it 'returns empty array' do
        expect(subject.get_feed).to eq([])
      end
    end
    context 'when response does not include expected feed elements' do
      let(:grad_milestones_response) { {feed: {}} }
      it 'returns empty array' do
        expect(subject.get_feed).to eq([])
      end
    end
    context 'when response provides expected progresses' do
      it 'returns progresses' do
        expect(subject.get_feed).to eq ['Grad Milestone 1','Grad Milestone 2']
      end
    end
  end
end
