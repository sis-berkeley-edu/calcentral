describe GoogleApps::Userinfo do
  it 'Should return a valid user profile from fake data' do
    userinfo_proxy = GoogleApps::Userinfo.new :fake => true
    userinfo_proxy.class.api.should == 'userinfo'
    response = userinfo_proxy.user_info
    %w(emails name id).each do |key|
      response.data[key].blank?.should_not be_truthy
    end
    response.data['emails'].first['value'].should eq 'tammi.chang.clc@gmail.com'
  end
end
