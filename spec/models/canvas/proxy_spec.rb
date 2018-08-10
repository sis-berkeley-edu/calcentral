describe Canvas::Proxy do

  before do
    @user_id = Settings.canvas_proxy.test_user_id
    @client = Canvas::Proxy.new(:user_id => @user_id)
  end

  it 'should see an account list as admin' do
    admin_client = Canvas::Proxy.new
    admin_client.set_response(body: admin_client.read_file('fixtures', 'json', 'canvas_accounts.json'))
    accounts = admin_client.wrapped_get('accounts')[:body]
    expect(accounts).to_not be_empty
  end

  it 'should see the same account list as admin, initiating Canvas::Proxy with a passed in token' do
    admin_client = Canvas::Proxy.new(:access_token => Settings.canvas_proxy.admin_access_token)
    admin_client.set_response(body: admin_client.read_file('fixtures', 'json', 'canvas_accounts.json'))
    accounts = admin_client.wrapped_get('accounts')[:body]
    expect(accounts).to_not be_empty
  end

  describe 'url_root' do
    before do
      allow(Settings.canvas_proxy).to receive(:url_root).and_return('FROM_CONFIG')
    end
    it 'defaults to the configuration root' do
      client = Canvas::Proxy.new
      expect(client.api_root).to eq 'FROM_CONFIG/api/v1'
    end
    it 'can be overridden' do
      client = Canvas::Proxy.new(url_root: 'FROM_CALL')
      expect(client.api_root).to eq 'FROM_CALL/api/v1'
    end
  end

  it 'should get user activity feed using the Tammi account' do
    begin
      proxy = Canvas::UserActivityStream.new(:fake => true)
      response = proxy.user_activity
      user_activity = response[:body]
      expect(user_activity).to have(20).items
      required_fields = %w(created_at updated_at id type html_url)
      user_activity.each do |entry|
        (entry.keys & required_fields).size.should == required_fields.size
        expect {
          DateTime.parse(entry['created_at']) unless entry['created_at'].blank?
          DateTime.parse(entry['updated_at']) unless entry['update_at'].blank?
        }.to_not raise_error
        expect(entry['id']).to be_a Integer
        category_specific_id_exists = entry['course_id'] || entry['group_id'] || entry['conversation_id']
        expect(category_specific_id_exists).to be_present
      end
    ensure
      WebMock.reset!
    end
  end

  it 'should fetch all course students even if the Canvas feed is paged' do
    # The mock JSON has been edited to have four pages of results, only one student per page.
    students = Canvas::CourseStudents.new(course_id: 767330, fake: true).full_students_list[:body]
    expect(students).to have(4).items
  end

  it 'should find a registered user profile' do
    profile = Canvas::SisUserProfile.new(user_id: @user_id).sis_user_profile
    expect(profile[:statusCode]).to eq 200
    expect(profile[:body]).to be_present
  end

  describe '.sis_term_id_to_term' do
    it 'converts sis term id to term hash' do
      result = Canvas::Terms.sis_term_id_to_term('TERM:2014-D')
      expect(result).to include(term_yr: '2014', term_cd: 'D')
    end

    it 'returns nil if sis term id not formatted properly' do
      expect(Canvas::Terms.sis_term_id_to_term('TERMS:2014-D')).to be_nil
      expect(Canvas::Terms.sis_term_id_to_term('TERM:20147.D')).to be_nil
      expect(Canvas::Terms.sis_term_id_to_term('TERM:2014-DB')).to be_nil
      expect(Canvas::Terms.sis_term_id_to_term('TERM:2014-d')).to be_nil
    end
  end

  context 'on server errors' do
    before { stub_request(:any, /.*#{Settings.canvas_proxy.url_root}.*/).to_return(status: 404, body: 'Resource not found.') }
    let(:course_students) { Canvas::CourseStudents.new(course_id: 767330, fake: false) }
    subject { course_students.full_students_list[:body] }

    it_behaves_like 'a proxy logging errors'
    it_behaves_like 'a polite HTTP client'

    it 'should log DEBUG for 404 errors when existence_check is true' do
      allow_any_instance_of(Canvas::CourseStudents).to receive(:existence_check).and_return(true)
      expect(Rails.logger).not_to receive(:error)
      expect(Rails.logger).to receive(:debug).at_least(2).times
      course_students.full_students_list
    end
  end

end
