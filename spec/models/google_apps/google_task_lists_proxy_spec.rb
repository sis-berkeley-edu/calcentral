describe GoogleApps::Proxy do

  before(:each) do
    @random_id = Time.now.to_f.to_s.gsub(".", "")
  end

  it "should simulate a fake, valid task list response (assuming a valid recorded fixture)" do
    #Pre-recorded response has 14 entries, split into batches of 10.
    proxy = GoogleApps::TasksList.new(:fake => true)
    response = proxy.tasks_list.first

    #sample response payload: https://developers.google.com/google-apps/tasks/v1/reference/tasks/list
    response.data["kind"].should == "tasks#tasks"
    response.data["items"].size.should == 7
  end
end
