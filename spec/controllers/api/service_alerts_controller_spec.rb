describe Api::ServiceAlertsController do
  def response_json
    JSON.parse(response.body)
  end

  def json_keys
    %w(
      id
      title
      body
      snippet
      publication_date
      display
      splash_only
    )
  end

  describe "index" do
    before do
      create :service_alert, title: "First Service Alert"
      create :service_alert, title: "Second Service Alert"
    end

    after do
    end

    it "returns unauthorized if not signed in" do
      get :index
      expect(response).to be_unauthorized
    end

    it "returns unauthorized if permissions are not sufficient" do
      session[:user_id] = create(:user_auth).uid
      get :index
      expect(response).to be_unauthorized
    end

    it "returns JSON for the service alerts" do
      session[:user_id] = create(:superuser_auth).uid
      get :index
      expect(response).to be_successful
      expect(response_json["current_page"]).to eq 1
      expect(response_json["total_pages"]).to eq 1
      expect(response_json["service_alerts"].length).to eq(2)
      expect(response_json["service_alerts"][0]["title"]).to eq "First Service Alert"
      expect(response_json["service_alerts"][1]["title"]).to eq "Second Service Alert"
    end
  end

  describe "create" do
    describe "authorization" do
      it "is unauthorized when not signed in" do
        post :create
        expect(response).to be_unauthorized
      end

      it "is unauthorized as normal user or viewer" do
        [create(:user_auth), create(:viewer_auth)].each do |auth|
          session[:user_id] = auth.uid
          post :create
          expect(response).to be_unauthorized
        end
      end

      it "successful as author or superuser" do
        [create(:author_auth), create(:superuser_auth)].each do |auth|
          session[:user_id] = auth.uid
          post :create, params: { service_alert: attributes_for(:service_alert) }
          expect(response).to be_created
        end
      end
    end

    describe "success" do
      it "creates service alert with title, body, publication_date" do
        attributes = attributes_for(:service_alert)
        session[:user_id] = create(:author_auth).uid
        post :create, params: {service_alert: attributes}
        expect(response).to be_created
        expect(response_json.keys).to eq json_keys
      end
    end

    describe "failure" do
      before do
        auth = create(:author_auth)
        session[:user_id] = auth.uid
      end

      describe "with invalid title" do
        before do
          post :create, params: {
            service_alert: attributes_for(:service_alert).merge({
              title: ""
            })
          }
        end

        it "returns 422 Unprocessable Entity" do
          expect(response).to be_unprocessable
        end

        it "renders errors" do
          expect(response_json).to eq({ "title" => ["can't be blank"] })
        end
      end
    end
  end

  describe "update" do
    let!(:service_alert) { create :service_alert }

    describe "with valid auth" do
      before do
        session[:user_id] = create(:author_auth).uid
      end

      describe "success" do
        it "updates the attributes" do
          patch :update, params: {
            id: service_alert.id, service_alert: {
              title: "Vote",
              body: "<p>Updated body</p>",
              publication_date: "2020-11-03",
              display: false,
              splash_only: false
            }
          }

          expect(response).to be_ok
          expect(response_json.keys).to eq json_keys
          expect(response_json["title"]).to eq "Vote"
          expect(response_json["body"]).to eq "<p>Updated body</p>"
          expect(response_json["publication_date"]).to eq "2020-11-03"
          expect(response_json["display"]).to be(false)
          expect(response_json["splash_only"]).to be(false)
        end
      end

      describe "failure" do
        before do
          patch :update, params: {
            id: service_alert.id, service_alert: {
              title: ""
            }
          }
        end

        it "returns 422 Unprocessable Entity" do
          expect(response).to be_unprocessable
        end

        it "renders errors" do
          expect(response_json).to eq({ "title" => ["can't be blank"] })
        end
      end
    end
  end
end
