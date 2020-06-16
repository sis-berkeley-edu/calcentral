describe GoogleApps::DriveList do

  it 'Should return a valid list of drive files' do
    drive_list_proxy = GoogleApps::DriveList.new :fake => true
    response = drive_list_proxy.drive_list
    expect(response).to be_an Enumerable
    response.each do |response_page|
      expect(response_page.class).to eq Google::Apis::DriveV2::FileList
      expect(response_page.kind).to eq 'drive#fileList'
      expect(response_page.items).to be_an Array
    end
  end

end
