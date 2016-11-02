describe AdvisingStudentController do

  let(:session_user_id) { nil }
  let(:session_user_is_advisor) { false }
  let(:session_user_attributes) { { roles: { advisor: session_user_is_advisor } } }
  let(:student) { false }
  let(:ex_student) { false }
  let(:applicant) { false }
  let(:student_uid) { random_id }
  let(:student_attributes) {
    {
      roles: {
        student: student,
        exStudent: ex_student,
        applicant: applicant
      }
    }
  }
  let(:academics_feed) do
    {collegeAndLevel: true}
  end

  before do
    session['user_id'] = session_user_id
    allow(User::AggregatedAttributes).to receive(:new).with(student_uid).and_return double get_feed: student_attributes
    allow(User::AggregatedAttributes).to receive(:new).with(session_user_id).and_return double get_feed: session_user_attributes
  end

  shared_examples 'an endpoint receiving an unauthenticated request' do
    it 'should return empty json' do
      expect(JSON.parse subject.body).to be_empty
    end
  end

  shared_examples 'an endpoint refusing a request' do
    it 'should raise an error' do
      expect(subject.status).to eq 403
    end
  end

  shared_examples 'an endpoint receiving a valid request' do
    it 'should send a successful response' do
      expect(subject.status).to eq 200
    end
  end

  describe '#academics' do
    let(:session_user_id) { random_id }
    before do
      allow(MyAcademics::FilteredForAdvisor).to receive(:new).with(student_uid, anything).and_return double get_feed_as_json: academics_feed.to_json
      expect(MyAcademics::Merged).to receive(:new).never
    end
    subject { get :academics, student_uid: student_uid }

    context 'cannot view_as for all UIDs' do
      it_behaves_like 'an endpoint refusing a request'
    end
    context 'requested user must be a student' do
      let(:session_user_is_advisor) { true }

      context 'feature flag false' do
        let(:student) { true }
        before do
          allow(Settings.features).to receive(:cs_advisor_student_lookup).and_return false
        end
        it_behaves_like 'an endpoint refusing a request'
      end
      context 'not a student' do
        it_behaves_like 'an endpoint refusing a request'
      end
      context 'student' do
        let(:student) { true }
        it_behaves_like 'an endpoint receiving a valid request'
        it 'should provide a filtered academics feed' do
          feed = JSON.parse(body = subject.body)
          expect(feed['collegeAndLevel']).to eq true
        end
      end
      context 'ex-student' do
        let(:ex_student) { true }
        it_behaves_like 'an endpoint receiving a valid request'
        it 'should provide a filtered academics feed' do
          feed = JSON.parse(body = subject.body)
          expect(feed['collegeAndLevel']).to eq true
        end
      end
      context 'applicant' do
        let(:applicant) { true }
        it_behaves_like 'an endpoint receiving a valid request'
        it 'should return data' do
          feed = JSON.parse(body = subject.body)
          expect(feed['collegeAndLevel']).to eq true
        end
      end
    end
  end

  describe '#profile' do
    subject { get :profile, student_uid: student_uid }

    context 'when no user in session' do
      let(:student_id) { nil }
      it_behaves_like 'an endpoint receiving an unauthenticated request'
    end

    context 'student' do
      before do
        allow(HubEdos::Contacts).to receive(:new).and_return double get: {}
      end
      let(:session_user_id) { random_id }
      let(:session_user_is_advisor) { true }
      let(:student) { true }

      it_behaves_like 'an endpoint receiving a valid request'
      it 'should return data' do
        roles = (JSON.parse subject.body)['attributes']['roles']
        student_attributes[:roles].each do |key, value|
          expect(roles[key.to_s]).to be value
        end
      end
    end
  end

  describe '#degree_progress_graduate' do
    subject { get :degree_progress_graduate, student_uid: student_uid }

    before do
      allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_view_as?).and_return(true)
    end

    context 'when no user in session' do
      let(:student_id) { nil }
      it_behaves_like 'an endpoint receiving an unauthenticated request'
    end

    context 'student' do
      let(:session_user_id) { random_id }
      let(:session_user_is_advisor) { true }
      let(:student) { true }

      it_behaves_like 'an endpoint receiving a valid request'
      it 'should return data' do
        feed = JSON.parse(body = subject.body)
        expect(feed['feed']['degreeProgress']).to be
        expect(feed['feed']['links']).not_to be
      end
    end
  end

  describe '#degree_progress_undergrad' do
    let(:session_user_id) { random_id }

    subject { get :degree_progress_undergrad, student_uid: student_uid }

    context 'student' do
      let(:session_user_is_advisor) { true }
      let(:student) { true }
      it 'should succeed' do
        expect(subject.status).to eq 200
        data = JSON.parse subject.body
        expect(data).to be
      end
    end
  end

end
