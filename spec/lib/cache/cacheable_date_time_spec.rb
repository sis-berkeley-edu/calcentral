describe Cache::CacheableDateTime do

  let(:cacheable_now) { described_class.new(Time.now.in_time_zone.to_datetime) }

  shared_examples 'a cacheable datetime' do
    it 'survives dehydration and rehydration intact' do
      duplicate_datetime = Marshal.load(Marshal.dump cacheable_datetime)
      expect(duplicate_datetime).to eq cacheable_datetime
      expect(duplicate_datetime.offset).to eq cacheable_datetime.offset
    end
  end

  context 'up to the moment' do
    let(:cacheable_datetime) { cacheable_now }
    it_should_behave_like 'a cacheable datetime'
  end

  context 'the news from next week' do
    let(:cacheable_datetime) { cacheable_now.advance(days: 7) }
    it_should_behave_like 'a cacheable datetime'
  end

  context 'when the day is done' do
    let(:cacheable_datetime) { cacheable_now.end_of_day }
    it_should_behave_like 'a cacheable datetime'
  end

end
