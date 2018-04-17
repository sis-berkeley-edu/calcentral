describe AdvisingStudentController do
  before do
    allow(Settings.hub_edos_proxy).to receive(:fake).and_return true
  end

  let(:session_user_id) { nil }
  let(:session_user_is_advisor) { false }
  let(:session_user_attributes) { { roles: { advisor: session_user_is_advisor } } }
  let(:student) { false }
  let(:ex_student) { false }
  let(:applicant) { false }
  let(:confidential) { false }
  let(:student_uid) { random_id }
  let(:student_attributes) {
    {
      roles: {
        student: student,
        exStudent: ex_student,
        applicant: applicant,
        confidential: confidential
      }
    }
  }

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

  describe '#profile' do
    subject { get :profile, student_uid: student_uid }

    context 'when no user in session' do
      it_behaves_like 'an endpoint receiving an unauthenticated request'
    end
    context 'when advisor authorized' do
      let(:session_user_id) { random_id }
      let(:session_user_is_advisor) { true }

      context 'when viewing a student' do
        let(:student) { true }
        it_behaves_like 'an endpoint receiving a valid request'
        it 'should return data' do
          feed = JSON.parse subject.body
          expect(feed['academicRoles']).to be
          expect(feed['attributes']).to be
          expect(feed['attributes']['roles']).to be
          expect(feed['contacts']['feed']).to be
          expect(feed['residency']['residency']).to be
        end
        context 'when viewing a confidential student' do
          let(:confidential) { true }
          let(:student) { true }
          it_behaves_like 'an endpoint refusing a request'
        end
      end
    end
  end

  describe '#academics' do
    let(:session_user_id) { random_id }
    before do
      expect(MyAcademics::Merged).to receive(:new).never
    end
    subject { get :academics, student_uid: student_uid }

    context 'when not advisor authorized' do
      it_behaves_like 'an endpoint refusing a request'
    end
    context 'when advisor authorized' do
      let(:session_user_is_advisor) { true }

      context 'when not viewing a student' do
        it_behaves_like 'an endpoint refusing a request'
      end
      context 'when viewing a student' do
        let(:student) { true }

        it_behaves_like 'an endpoint receiving a valid request'
        it 'should provide a filtered academics feed' do
          feed = JSON.parse(body = subject.body)
          expect(feed['collegeAndLevel']).to be
        end

        context 'when feature flag is false' do
          let(:student) { true }
          before do
            allow(Settings.features).to receive(:cs_advisor_student_lookup).and_return false
          end
          it_behaves_like 'an endpoint refusing a request'
        end
      end
      context 'when viewing an ex-student' do
        let(:ex_student) { true }
        it_behaves_like 'an endpoint receiving a valid request'
        it 'should provide a filtered academics feed' do
          feed = JSON.parse(body = subject.body)
          expect(feed['collegeAndLevel']).to be
        end
      end
      context 'when viewing an applicant' do
        let(:applicant) { true }
        it_behaves_like 'an endpoint receiving a valid request'
        it 'should return data' do
          feed = JSON.parse(body = subject.body)
          expect(feed['collegeAndLevel']).to be
        end
      end
      context 'when viewing a confidential student' do
        let(:student) { true }
        let(:confidential) { true }
        it_behaves_like 'an endpoint refusing a request'
      end
    end
  end

  describe '#academic_status' do
    let(:session_user_id) { random_id }
    subject { get :academic_status, student_uid: student_uid }

    context 'when not advisor authorized' do
      it_behaves_like 'an endpoint refusing a request'
    end
    context 'when advisor asuthorized' do
      let(:session_user_is_advisor) { true }

      context 'when not viewing a student' do
        it_behaves_like 'an endpoint refusing a request'
      end
      context 'when viewing a student' do
        let(:student) { true }

        it_behaves_like 'an endpoint receiving a valid request'
        it 'should provide a filtered academics feed' do
          feed = JSON.parse(body = subject.body)
          expect(feed['feed']).to be
        end
      end
    end
  end

  describe '#degree_progress_graduate' do
    subject { get :degree_progress_graduate, student_uid: student_uid }
    let(:session_user_id) { random_id }

    context 'when not advisor authorized' do
      it_behaves_like 'an endpoint refusing a request'
    end
    context 'when advisor authorized' do
      before do
        allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_view_as?).and_return(true)
      end
      let(:session_user_is_advisor) { true }

      context 'when viewing a student' do
        let(:student) { true }
        it_behaves_like 'an endpoint receiving a valid request'
        it 'should return data' do
          feed = JSON.parse(body = subject.body)
          expect(feed['feed']['degreeProgress']).to be
        end
      end
    end
  end

  describe '#degree_progress_undergrad' do
    subject { get :degree_progress_undergrad, student_uid: student_uid }
    let(:session_user_id) { random_id }

    context 'when not advisor authorized' do
      it_behaves_like 'an endpoint refusing a request'
    end
    context 'when advisor authorized' do
      before do
        allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_view_as?).and_return(true)
      end
      let(:session_user_is_advisor) { true }
      context 'when viewing a student' do
        let(:student) { true }
        it_behaves_like 'an endpoint receiving a valid request'
        it 'should return data' do
          feed = JSON.parse(body = subject.body)
          expect(feed['feed']['degreeProgress']).to be
        end
      end
    end
  end

  describe '#holds' do
    let(:session_user_id) { random_id }
    subject { get :holds, student_uid: student_uid }

    context 'when not advisor authorized' do
      it_behaves_like 'an endpoint refusing a request'
    end
    context 'when advisor authorized' do
      let(:session_user_is_advisor) { true }

      context 'when not viewing a student' do
        it_behaves_like 'an endpoint refusing a request'
      end
      context 'when viewing a student' do
        let(:student) { true }

        it_behaves_like 'an endpoint receiving a valid request'
        it 'should provide a filtered academics feed' do
          feed = JSON.parse(body = subject.body)
          expect(feed['feed']['holds']).to be
        end
      end
      context 'when viewing an ex-student' do
        let(:ex_student) { true }
        it_behaves_like 'an endpoint receiving a valid request'
        it 'should provide a filtered academics feed' do
          feed = JSON.parse(body = subject.body)
          expect(feed['feed']['holds']).to be
        end
      end
      context 'when viewing an applicant' do
        let(:applicant) { true }
        it_behaves_like 'an endpoint receiving a valid request'
        it 'should return data' do
          feed = JSON.parse(body = subject.body)
          expect(feed['feed']['holds']).to be
        end
      end
      context 'when viewing a confidential student' do
        let(:student) { true }
        let(:confidential) { true }
        it_behaves_like 'an endpoint refusing a request'
      end
    end
  end
end
