describe DegreeProgress::GraduateMilestones do

  let(:model) { described_class.new(user_id) }
  let(:user_id) { '12345' }

  describe '#get_feed_internal' do
    subject { model.get_feed_internal }

    it_behaves_like 'a proxy that returns graduate milestone data'

    it 'does not include links in the response' do
      expect(subject[:feed][:links]).not_to be
    end
  end
end
