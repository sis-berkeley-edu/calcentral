describe User::Visit do

  describe '#record' do
    subject { described_class.record uid }

    before do
      allow(Settings.features).to receive(:user_visits).and_return user_visits_feature_flag\
    end
    let(:uid) { rand(9999999).to_s }

    context 'when feature flag is on' do
      let(:user_visits_feature_flag) { true }
      it 'should record a user\'s visit' do
        expect(subject).to be_truthy
      end
    end
    context 'when feature flag is off' do
      let(:user_visits_feature_flag) { false }
      it 'should not record a user\'s visit' do
        expect(subject).to be nil
      end
    end
  end
end
