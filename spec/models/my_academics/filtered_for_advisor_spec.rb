describe MyAcademics::FilteredForAdvisor do
  before do
    MyAcademics::FilteredForAdvisor.providers.each do |provider_class|
      provider = double
      allow(provider).to receive(:merge) do |feed|
        feed[provider_class.to_s] = true
      end
      allow(provider_class).to receive(:new).and_return provider
    end
  end
  it 'only includes a subset of providers' do
    unfiltered_provider_classes = MyAcademics::Merged.providers
    filtered_provider_classes = MyAcademics::FilteredForAdvisor.providers
    expect(filtered_provider_classes.length).to be < unfiltered_provider_classes.length
    verboten_provider_classes = unfiltered_provider_classes - filtered_provider_classes
    feed = JSON.parse described_class.new(random_id).get_feed_as_json
    filtered_provider_classes.map do |provider_class|
      expect(feed[provider_class.to_s]).to eq true
    end
    verboten_provider_classes.map do |provider_class|
      expect(feed[provider_class.to_s]).to be_nil
    end
  end
end
