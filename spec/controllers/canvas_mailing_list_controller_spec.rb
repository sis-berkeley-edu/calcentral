describe CanvasMailingListController do
  let(:canvas_course_id) { rand(99999) }

  shared_examples 'a protected controller' do
    let(:user_id) { rand(99999).to_s }
    before do
      session['user_id'] = user_id
      allow_any_instance_of(Canvas::SisUserProfile).to receive(:get).and_return({
        'id' => user_id
      })
      allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).with(user_id).and_return(is_admin)
      allow(Canvas::CourseUser).to receive(:new).with(user_id: user_id, course_id: canvas_course_id).and_return(
        double(course_user: course_user)
      )
    end

    shared_examples 'not authorized' do
      it 'forbids list lookup' do
        expect(MailingLists::SiteMailingList).to_not receive(:find_or_initialize_by)
        lookup_request
        expect(response.status).to eq(403)
      end

      it 'forbids list creation' do
        expect(MailingLists::MailgunList).to_not receive(:create!)
        create_request
        expect(response.status).to eq(403)
      end
    end

    shared_examples 'authorized' do
      it 'allows list lookup' do
        expect(MailingLists::SiteMailingList).to receive(:find_or_initialize_by).and_call_original
        lookup_request
        expect(response.status).to eq 200
        response_json = JSON.parse(response.body)
        expect(response_json['mailingList']['state']).to eq 'unregistered'
      end

      it 'allows list creation' do
        expect(MailingLists::MailgunList).to receive(:create!).and_call_original
        create_request
        expect(response.status).to eq 200
        response_json = JSON.parse(response.body)
        expect(response_json['mailingList']['state']).to eq 'created'
      end
    end

    context 'when user is not in the course site' do
      let(:is_admin) { false }
      let(:course_user) { nil }
      include_examples 'not authorized'
    end

    context 'when user is a student in the course site' do
      let(:is_admin) { false }
      let(:course_user) { {'enrollments' => [{'role' => 'StudentEnrollment'}]} }
      include_examples 'not authorized'
    end

    context 'when user is a teacher in the course site' do
      let(:is_admin) { false }
      let(:course_user) { {'enrollments' => [{'role' => 'TeacherEnrollment'}]} }
      include_examples 'authorized'
    end

    context 'when user is a Canvas admin' do
      let(:is_admin) { true }
      let(:course_user) { nil }
      include_examples 'authorized'
    end
  end

  let(:make_request) { lookup_request }

  context 'in CalCentral context with explicit Canvas course ID' do
    let(:lookup_request) { get :show, canvas_course_id: canvas_course_id.to_s }
    let(:create_request) { post :create, canvas_course_id: canvas_course_id.to_s }
    it_behaves_like 'a user authenticated api endpoint'
    it_behaves_like 'a protected controller'
  end

  context 'in LTI context' do
    let(:lookup_request) { get :show, canvas_course_id: 'embedded' }
    let(:create_request) { post :create, canvas_course_id: 'embedded' }
    before do
      session['canvas_course_id'] = canvas_course_id.to_s
    end
    it_behaves_like 'a protected controller'
  end
end
