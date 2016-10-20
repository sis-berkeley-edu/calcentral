describe DegreeProgress::UndergradRequirements do

  let(:model) { described_class.new(user_id) }
  let(:user_id) { '12345' }

  describe '#get_feed_internal' do
    subject { model.get_feed_internal }

    it_behaves_like 'a proxy that returns undergraduate milestone data'
  end
end
