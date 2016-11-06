describe MyCommitteesController do

  let(:uid) {random_id}
  let(:student_id) {'12345' }
  let(:member_id) {'12345' }

  let(:photo_file) { {:data => '\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01'} }

  before do
    session['user_id'] = uid
  end

  it 'should be an empty committees feed on non-authenticated user' do
    session['user_id'] = nil
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it 'should return a valid committees feed for an authenticated user' do
    session['user_id'] = uid
    dummy = JSON.parse(File.read(Rails.root.join('public/dummy/json/committees.json')))
    MyCommittees::Merged.any_instance.stub(:get_feed).and_return(dummy)
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response['studentCommittees'].instance_of?(Array).should == true
    json_response['facultyCommittees']['active'].instance_of?(Array).should == true
    json_response['facultyCommittees']['completed'].instance_of?(Array).should == true
  end

  context 'when serving committee student photo' do
    it_should_behave_like 'an api endpoint' do
      before { allow_any_instance_of(MyCommittees::Merged).to receive(:get_feed_as_json).and_raise(RuntimeError, 'Something went wrong') }
      let(:make_request) { get :student_photo, student_id: student_id }
    end

    it_should_behave_like 'a user authenticated api endpoint' do
      let(:make_request) { get :student_photo, student_id: student_id }
    end

    context 'user is not authorized to view photo' do
      it 'should return 403 response' do
        allow_any_instance_of(MyCommittees::Merged).to receive(:get_feed_as_json).and_return('')
        get :student_photo, student_id: student_id
        expect(response).to have_http_status(403)
      end
    end

    context 'if photo path returned ' do
      before { allow_any_instance_of(MyCommittees::Merged).to receive(:photo_data_or_file).and_return(photo_file) }
      it 'should return photo' do
        get :student_photo, student_id: student_id
        assert_response :success
      end
    end
  end

  context 'when serving committee member photo' do
    it_should_behave_like 'an api endpoint' do
      before { allow_any_instance_of(MyCommittees::Merged).to receive(:get_feed_as_json).and_raise(RuntimeError, 'Something went wrong') }
      let(:make_request) { get :member_photo, member_id: member_id }
    end

    it_should_behave_like 'a user authenticated api endpoint' do
      let(:make_request) { get :member_photo, member_id: member_id }
    end

    context 'user is not authorized to view photo' do
      it 'should return 403 response' do
        allow_any_instance_of(MyCommittees::Merged).to receive(:get_feed_as_json).and_return('')
        get :member_photo, member_id: member_id
        expect(response).to have_http_status(403)
      end
    end

    context 'if photo path returned ' do
      before { allow_any_instance_of(MyCommittees::Merged).to receive(:photo_data_or_file).and_return(photo_file) }
      it 'should return photo' do
        get :member_photo, member_id: member_id
        assert_response :success
      end
    end
  end
end
