describe GoogleApps::EventsInsert do
  let(:user_id) { rand(999999).to_s }
  let!(:valid_payload) do
    {
      'calendarId' => 'primary',
      'summary' => 'Fancy event',
      'start' => {
        'dateTime' => '2013-09-24T02:06:00.000-07:00'
      },
      'end' => {
        'dateTime' => '2013-09-24T03:06:00.000-07:00'
      }
    }
  end
  let(:invalid_payload) do
    {
      'calendarId' => 'primary',
      'summary' => 'Fancy event',
      'start' => {
        'dateTime' => '2013-09-24T02:06:00.000-07:00'
      },
      'end' => {
        'dateTime' => '2013-09-24T03:06:00.000-07:0'
      }
    }
  end
  let(:fake_proxy) do
    fake_proxy = GoogleApps::EventsInsert.new(fake: true)
  end

  shared_examples "200 insert event task" do
    its(:status) { should eq(200) }
    it { subject.data["summary"].should eq("Fancy event")}
    it { subject.data["status"].should eq("confirmed") }
  end

  shared_examples "4xx insert event task" do
    its(:status) { should eq(400) }
    it { subject.data.should_not be_blank }
    it { subject.data.error.should_not be_blank }
  end

  context "fake insert event test", if: Rails.env.test? do
    context "valid payload" do
      subject { fake_proxy.insert_event(valid_payload) }
      it_behaves_like "200 insert event task"
    end

    context "invalid payload" do
      subject {
        fake_proxy.json_filename = 'google_events_insert_invalid.json'
        fake_proxy.set_response({status: 400})
        fake_proxy.insert_event(invalid_payload)
      }
      it_behaves_like "4xx insert event task"
    end
  end
end
