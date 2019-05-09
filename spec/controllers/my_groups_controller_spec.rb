describe MyGroupsController do

  let(:uid) {random_id}

  it "should be an empty course sites feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it "should check for valid fields on the my groups feed" do
    session['user_id'] = uid
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response["groups"].is_a?(Array).should == true
    json_response["groups"].each do |group_entry|
      group_entry["id"].blank?.should_not == true
      group_entry["site_url"].blank?.should_not == true
      (group_entry["emitter"] =~ (/(bcourses|callink)$/i)).should_not be_nil
    end
  end

  let(:make_request) { get :get_feed }
  it_should_behave_like 'a user authenticated api endpoint'
  it_behaves_like 'an unauthorized endpoint for delegates'
  it_behaves_like 'an unauthorized endpoint for LTI'

  context 'using test data' do
    subject do
      get :get_feed
      JSON.parse(response.body)
    end
    before do
      allow(Settings.canvas_proxy).to receive(:fake).at_least(:once).and_return(true)
      allow(Settings.cal_link_proxy).to receive(:fake).at_least(:once).and_return(true)
    end
    it 'returns a varied feed' do
      session['user_id'] = uid
      expect(subject['groups'].index {|c| c['emitter'] == 'CalLink'}).to_not be_nil
      expect(subject['groups'].index {|c| c['emitter'] == 'bCourses'}).to_not be_nil
    end
    context 'advisor view-as' do
      include_context 'advisor view-as'
      it 'filters bCourses groups' do
        expect(subject['groups'].index {|c| c['emitter'] == 'CalLink'}).to_not be_nil
        expect(subject['groups'].index {|c| c['emitter'] == 'bCourses'}).to be_nil
      end
    end
  end
end
