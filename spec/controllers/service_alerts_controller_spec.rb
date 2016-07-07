describe ServiceAlertsController, :testext => true do

  before do
    allow(ServiceAlerts::Alert).to receive(:get_latest).and_return(fake_alert)
  end

  context 'when there is an alert' do
    let(:fake_alert) do
      ServiceAlerts::Alert.create!(
        title: 'CalCentral alerts and release notes are unavailable',
        body: '<p>As of this morning, Friday, August 7, 2015, the CalCentral web application lost access to system-wide alerts and information on the latest release.</p> <p>We expect the problem to be resolved with the next maintenance update of CalCentral, scheduled for Sunday, August 9, 2015, between 10:00am  and 11:00am.</p>'
      )
    end

    it 'should return both an alert and a release note for non-authenticated users' do
      get :get_feed
      assert_response :success
      expect(response.status).to eq 200
      json_response = JSON.parse(response.body)
      expect(json_response['alert']).to be_present
      expect(json_response['releaseNote']).to be_present
    end
  end

  context 'when there are no alerts' do
    let(:fake_alert) { nil }
    it 'should return only a release note for non-authenticated users' do
      get :get_feed
      assert_response :success
      expect(response.status).to eq 200
      json_response = JSON.parse(response.body)
      expect(json_response['alert']).to be_blank
      expect(json_response['releaseNote']).to be_present
    end
  end

end
