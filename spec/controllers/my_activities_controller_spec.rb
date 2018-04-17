describe MyActivitiesController do

  let(:uid) {random_id}

  it "should be an empty activities feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it "should return a valid activities feed for an authenticated user" do
    session['user_id'] = uid
    dummy = JSON.parse(File.read(Rails.root.join('public/dummy/json/activities.json')))
    MyActivities::Merged.any_instance.stub(:get_feed).and_return(dummy)
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response["activities"].instance_of?(Array).should == true
    json_response["activities"].each do | activity |
      %w(type source emitter).each do | req_field |
        activity[req_field].blank?.should_not == true
      end
    end
  end

  # The Activities feed merges so many sources that it would be difficult to
  # explicitly fake them all.
  if ENV['RAILS_ENV'] == 'test'
    context 'using test data' do
      subject do
        get :get_feed
        JSON.parse(response.body)
      end
      it 'returns a varied feed' do
        session['user_id'] = uid
        expect(subject['activities'].index {|c| c['emitter'] == 'Campus Solutions'}).to_not be_nil
        expect(subject['activities'].index {|c| c['emitter'] == 'bCourses'}).to_not be_nil
      end

      context 'advisor view-as' do
        include_context 'advisor view-as'
        it 'filters bCourses activities' do
          expect(subject['activities'].index {|c| c['emitter'] == 'Campus Solutions'}).to_not be_nil
          expect(subject['activities'].index {|c| c['emitter'] == 'bCourses'}).to be_nil
        end
      end
    end

    context 'delegated access' do
      let(:campus_solutions_id) {random_id}
      include_context 'delegated access'
      context 'enrollments-only access' do
        let(:privileges) do
          {
            viewEnrollments: true
          }
        end
        it 'denies all access' do
          get :get_feed
          expect(response.status).to eq 403
          expect(response.body).to eq ''
        end
      end
      context 'financial access' do
        let(:privileges) do
          {
            financial: true
          }
        end
        it 'allows access only to Financial Aid tasks' do
          get :get_feed
          assert_response :success
          json_response = JSON.parse(response.body)
          json_response.should be_present
          cs_finaid_activities = json_response['activities'].select {|t| (t['emitter'] == 'Campus Solutions') && t['cs']['isFinaid']}
          expect(cs_finaid_activities).to be_present
          expect(json_response['activities']).to eq cs_finaid_activities
        end
      end
    end

  end

end
