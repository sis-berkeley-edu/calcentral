describe MyAcademics::Merged do
  let(:provider_classes) do
    [
      MyAcademics::CollegeAndLevel,
      MyAcademics::GpaUnits,
      MyAcademics::Semesters,
      MyAcademics::Teaching,
      MyAcademics::TransferCredit,
      MyAcademics::Exams,
      MyAcademics::CanvasSites
    ]
  end

  let(:uid) { '61889' }

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
      provider_classes.each { |provider_class| expect(feed[provider_class.to_s]).to eq true }
      expect(feed[:errors]).to be_blank
    end
  end

  context 'when a provider misbehaves' do
    before do
      bad_provider = oski_providers.delete MyAcademics::Exams
      expect(bad_provider).to receive(:merge).and_raise NoMethodError
      set_mock_merge oski_providers
    end

    it 'should merge other providers and report error' do
      expect(Rails.logger).to receive(:error).with /Failed to merge MyAcademics::Exams for UID #{uid}: NoMethodError/
      feed = described_class.new(uid).get_feed_internal
      well_behaved_classes = provider_classes - [MyAcademics::Exams]
      well_behaved_classes.each { |well_behaved_class| expect(feed[well_behaved_class.to_s]).to eq true }
      expect(feed).not_to include 'MyAcademics::Exams'
      expect(feed[:errors]).to eq ['MyAcademics::Exams']
    end
  end
end
