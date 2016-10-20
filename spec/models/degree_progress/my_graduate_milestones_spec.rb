describe DegreeProgress::MyGraduateMilestones do

  let(:model) { described_class.new(user_id) }
  let(:user_id) { '12345' }

  describe '#get_feed_internal' do
    subject { model.get_feed_internal }

    it_behaves_like 'a proxy that returns graduate milestone data'

    it 'includes links in the response' do
      expect(subject[:feed][:links]).to be
      expect(subject[:feed][:links][:advancementFormSubmit]).to be
      expect(subject[:feed][:links][:advancementFormView]).to be
    end
  end
end
