describe MyFinancialsController do

  before(:each) do
    @user_id = rand(99999).to_s
  end

  it "should be an empty financials feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it "should be an non-empty financials feed on authenticated user" do
    Financials::MyFinancials.any_instance.stub(:get_feed).and_return(
      [{summary: "foo"}])
    session['user_id'] = @user_id
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response.size.should == 1
  end

  context 'delegated access' do
    let(:uid) {random_id}
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
      it 'allows access' do
        get :get_feed
        assert_response :success
        json_response = JSON.parse(response.body)
        json_response.should be_present
      end
    end
  end

end
