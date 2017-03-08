describe ServiceAlerts::Merged, :testext => true do
  let(:feed) { ServiceAlerts::Merged.new.get_feed_internal }

  shared_examples 'a feed with a release note' do
    it 'should include a well-formed release note' do
      release_note = feed[:releaseNote]
      expect(release_note.keys).to match_array [:title, :snippet, :timestamp, :link]
      expect(release_note.values).to all be_present
      expect(release_note[:timestamp].keys).to match_array [:epoch, :dateTime, :dateString]
      expect(release_note[:timestamp].values).to all be_present
    end
  end

  context 'when there are no alerts' do
    before do
      allow(ServiceAlerts::Alert).to receive(:get_latest).and_return nil
      allow(ServiceAlerts::Alert).to receive(:get_latest_splash).and_return nil
    end

    include_examples 'a feed with a release note'

    it 'should include no alert' do
      expect(feed[:alert]).to be_blank
    end
  end

  context 'when there is an alert' do
    before do
      allow(ServiceAlerts::Alert).to receive(:get_latest).and_return ServiceAlerts::Alert.create!(
        title: 'CalCentral alerts and release notes are unavailable',
        body: '<p>As of this morning, Friday, August 7, 2015, the CalCentral web application lost access to system-wide alerts and information on the latest release.</p> <p>We expect the problem to be resolved with the next maintenance update of CalCentral, scheduled for Sunday, August 9, 2015, between 10:00am  and 11:00am.</p>'
      )
      allow(ServiceAlerts::Alert).to receive(:get_latest_splash).and_return nil
    end

    include_examples 'a feed with a release note'

    it 'should include a well-formed alert feed item' do
      alert = feed[:alert]
      expect(alert.keys).to match_array [:title, :body, :timestamp]
      expect(alert.values).to all be_present
      expect(alert[:timestamp].keys).to match_array [:epoch, :dateTime, :dateString]
      expect(alert[:timestamp].values).to all be_present
    end
  end

  describe 'local DB overrides ETS Blog feed for splash page content' do
    before do
      allow(ServiceAlerts::Alert).to receive(:get_latest).and_return nil
      allow(ServiceAlerts::Alert).to receive(:get_latest_splash).and_return(ServiceAlerts::Alert.create!(
        title: 'Beware of the Blob!',
        body: '<p>It creeps and leaps and glides and slides across the floor.</p>'
      ))
      expect(EtsBlog::ReleaseNotes).to receive(:new).never
    end
    it 'should include a trimmer release note' do
      release_note = feed[:releaseNote]
      expect(release_note.keys).to match_array [:title, :body, :timestamp]
      expect(release_note.values).to all be_present
      expect(release_note[:timestamp].keys).to match_array [:epoch, :dateTime, :dateString]
      expect(release_note[:timestamp].values).to all be_present
    end
  end

end
