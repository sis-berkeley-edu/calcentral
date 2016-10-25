describe DegreeProgress::GraduateMilestones do

  let(:model) { described_class.new(user_id) }
  let(:user_id) { '12345' }

  before do
    allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_view_as?).and_return(can_view_as)
  end

  describe '#get_feed_internal' do
    subject { model.get_feed_internal }

    context 'when user has view-as privilege' do
      let(:can_view_as) { true }

      it_behaves_like 'a proxy that returns graduate milestone data'
      it_behaves_like 'a proxy that properly observes the graduate degree progress for advisor feature flag'

      it 'does not include links in the response' do
        expect(subject[:feed][:links]).not_to be
      end
    end

    context 'when user is not authorized' do
      let(:can_view_as) { false }

      it 'returns an empty response' do
        expect(subject).to eq({})
      end
    end
  end
end
