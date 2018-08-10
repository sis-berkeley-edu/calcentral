describe GoogleApps::EventsDelete do
  let(:user_id) { rand(999999).to_s }

  context "fake event deletion", if: Rails.env.test? do
    before(:each) do
      fake_proxy = GoogleApps::EventsDelete.new(fake: true)
      GoogleApps::EventsDelete.stub(:new).and_return(fake_proxy)
    end

    context "existing event" do
      subject { GoogleApps::EventsDelete.new(user_id).delete_event("evil_event") }

      its(:status) { should eq(204) }
      it { subject.response[:body].should be_blank }
    end

    context "non-existing event (404)" do
      subject {
        proxy = GoogleApps::EventsDelete.new(user_id)
        proxy.json_filename = 'google_events_delete_nonexistent.json'
        proxy.set_response({status: 404})
        proxy.delete_event("non_existent")
      }

      its(:status) { should eq(404) }
      it { subject.response[:body].should be_blank }
    end
  end
end
