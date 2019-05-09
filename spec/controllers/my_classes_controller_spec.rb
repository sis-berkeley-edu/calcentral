describe MyClassesController do

  before(:each) do
    @user_id = rand(99999).to_s
  end

  it "should be an empty course sites feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it "should be an non-empty course feed on authenticated user" do
    MyClasses::Merged.any_instance.stub(:get_feed).and_return(
      [{course_code: "PLEO 22",
      id: "750027",
      emitter: Canvas::Proxy::APP_NAME}])
    session['user_id'] = @user_id
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response.size.should == 1
    json_response[0]["course_code"].should == "PLEO 22"
  end

  let(:make_request) { get :get_feed }
  it_should_behave_like 'a user authenticated api endpoint'
  it_behaves_like 'an unauthorized endpoint for delegates'
  it_behaves_like 'an unauthorized endpoint for LTI'

  context 'test data', if: CampusOracle::Queries.test_data? do
    subject do
      get :get_feed
      JSON.parse(response.body)
    end
    before do
      allow(Settings.canvas_proxy).to receive(:fake).at_least(:once).and_return(true)
    end
    context 'student in test data' do
      let(:uid) {'300939'}
      it 'returns varied data' do
        session['user_id'] = uid
        expect(subject['classes'].index {|c| c['emitter'] == 'Campus'}).to_not be_nil
        expect(subject['classes'].index {|c| c['emitter'] == 'bCourses'}).to_not be_nil
      end
      context 'advisor view-as' do
        include_context 'advisor view-as'
        it 'filters bCourses sites' do
          expect(subject['classes'].index {|c| c['emitter'] == 'Campus'}).to_not be_nil
          expect(subject['classes'].index {|c| c['emitter'] == 'bCourses'}).to be_nil
        end
      end
    end
    context 'instructor in test data' do
      let(:uid) {'238382'}
      let(:instructing_classes) { subject['classes'].select {|c| c['role'] == 'Instructor'} }
      it 'includes instructing classes' do
        session['user_id'] = uid
        expect(instructing_classes).to be_present
      end
      context 'advisor view-as' do
        include_context 'advisor view-as'
        it 'filters out instructing classes' do
          expect(instructing_classes).to be_empty
        end
      end
    end
  end

end
