describe MyCommittees::Merged do
  let(:provider_classes) do
    [
      MyCommittees::StudentCommittees,
      MyCommittees::FacultyCommittees
    ]
  end

  let(:uid) { rand(99999).to_s  }

  let(:oski_providers) do
    provider_classes.each_with_object({}) do |provider_class, providers|
      providers[provider_class] = provider_class.new uid
    end
  end

  def set_mock_merge(providers)
    providers.each_value do |provider|
      expect(provider).to receive(:merge) do |feed|
        feed[provider.class.to_s] = true
      end
    end
  end

  before do
    oski_providers.each do |provider_class, oski_provider|
      allow(provider_class).to receive(:new).and_return oski_provider
    end
  end

  context 'when providers are well behaved' do
    before { set_mock_merge oski_providers }

    it 'should merge all providers into hash' do
      feed = described_class.new(uid).get_feed_internal
      provider_classes.each do |provider_class|
        expect(feed[provider_class.to_s]).to eq true
      end
      expect(feed[:errors]).to be_blank
    end
  end

end
