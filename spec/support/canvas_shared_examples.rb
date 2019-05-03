###############################################################################################
# Canvas Shared Examples
# ----------------------
#
# Used to provide test functionality that is shared across tests.
# See https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples
#
###############################################################################################

shared_examples 'a Canvas proxy handling request failure' do
  let (:status) { 500 }
  let (:body) { 'Internal Error' }
  before { subject.on_request(failing_request).set_response(status: status, body: body) }
  include_context 'expecting logs from server errors'
  it 'returns errors as objects' do
    expect(response[:statusCode]).to eq 503
    expect(response[:error]).to be_present
  end
end

shared_examples 'an unpaged Canvas proxy handling request failure' do
  include_examples 'a Canvas proxy handling request failure'
  it 'does not include a body' do
    expect(response).not_to include :body
  end
end

shared_examples 'a paged Canvas proxy handling request failure' do
  include_examples 'a Canvas proxy handling request failure'
  it 'returns an empty array as body' do
    expect(response[:body]).to eq []
  end
end

########################################################
# Canvas Controller Authorizations

shared_examples 'a canvas course admin authorized api endpoint' do

  let(:canvas_user_profile) do
    {
      'id'=>43232321,
      'name'=>'Michael Steven OWEN',
      'short_name'=>'Michael OWEN',
      'sortable_name'=>'OWEN, Michael',
      'sis_user_id'=>'UID:105431',
      'sis_login_id'=>'105431',
      'login_id'=>'105431',
      'avatar_url'=>'https://secure.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50',
      'title'=>nil,
      'bio'=>nil,
      'primary_email'=>'michael.s.owen@berkeley.edu',
      'time_zone'=>'America/Los_Angeles'
    }
  end

  let(:canvas_course_student_hash) do
    {
      'id' => 4321321,
      'name' => 'Michael Steven OWEN',
      'sis_user_id' => 'UID:105431',
      'sis_login_id' => '105431',
      'login_id' => '105431',
      'enrollments' => [
        {'course_id' => 767330, 'course_section_id' => 1312468, 'id' => 20241907, 'type' => 'StudentEnrollment', 'role' => 'StudentEnrollment'}
      ]
    }
  end

  let(:canvas_course_teacher_hash) do
    canvas_course_student_hash.merge({
      'enrollments' => [
        {'course_id' => 767330, 'course_section_id' => 1312468, 'id' => 20241908, 'type' => 'TeacherEnrollment', 'role' => 'TeacherEnrollment'}
      ]
    })
  end

  before do
    allow_any_instance_of(Canvas::UserProfile).to receive(:get).and_return canvas_user_profile
    allow_any_instance_of(Canvas::CourseUser).to receive(:course_user).and_return canvas_course_student_hash
    allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).and_return false
  end

  context 'when user is a student' do
    it 'returns 403 error' do
      make_request
      expect(response.status).to eq(403)
      expect(response.body).to eq ''
    end
  end

  context 'when user is a course teacher' do
    before { allow_any_instance_of(Canvas::CourseUser).to receive(:course_user).and_return canvas_course_teacher_hash }
    it 'returns 200 success' do
      make_request
      expect(response.status).to eq(200)
    end
  end

  context 'when user is a canvas account admin' do
    before { allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).and_return true }
    it 'returns 200 success' do
      make_request
      expect(response.status).to eq(200)
    end
  end

end
