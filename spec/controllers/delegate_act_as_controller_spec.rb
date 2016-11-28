describe DelegateActAsController do

  shared_examples 'successful view-as' do
    it 'succeeds' do
      post :start, uid: target_uid
      expect(response).to be_success
      expect(session['user_id']).to eq target_uid
      expect(session[SessionKey.original_delegate_user_id]).to eq real_user_id
    end
  end
  shared_examples 'failed view-as' do
    it 'fails' do
      post :start, uid: target_uid
      expect(response).to_not be_success
      expect(session['user_id']).to_not eq target_uid
      expect(session[SessionKey.original_delegate_user_id]).to be_nil
    end
  end

  describe '#start' do
    let(:target_uid) {'978966'}
    let(:target_roles) do
      {student: true}
    end
    let(:real_user_id) {'1021845'}
    let(:real_delegate) {true}

    before do
      session['user_id'] = real_user_id
      allow(Settings.features).to receive(:reauthentication).and_return(false)
      allow(User::Auth).to receive(:get).with(real_user_id).and_return(double(
        is_superuser?: false,
        is_viewer?: false,
        active?: true
      ))
      allow(User::AggregatedAttributes).to receive(:new).with(target_uid).and_return (double(
        get_feed: {roles: target_roles}
      ))
      allow(User::AggregatedAttributes).to receive(:new).with(real_user_id).and_return (double(
        get_feed: {roles: {}, isDelegateUser: real_delegate}
      ))
    end
    context 'delegate' do
      before do
        allow(CampusSolutions::DelegateStudents).to receive(:new).with(user_id: real_user_id).and_return (double(
          get: {statusCode: 200, feed: {students: [
            {uid: delegating_student_uid, privileges: {financial: true, viewEnrollments: true}}
          ]}}
        ))
      end
      context 'delegate seeks delegator' do
        let(:delegating_student_uid) {target_uid}
        it_behaves_like 'successful view-as'
      end
      context 'delegate seeks non-delegator' do
        let(:delegating_student_uid) {random_id}
        let(:target_roles) do
          {staff: true}
        end
        it_behaves_like 'failed view-as'
      end
      context 'delegate seeks confidential student' do
        let(:delegating_student_uid) {target_uid}
        let(:target_roles) do
          {student: true, confidential: true}
        end
        it_behaves_like 'successful view-as'
      end
    end
    context 'non-delegate seeks student' do
      let(:real_delegate) {false}
      before do
        allow(CampusSolutions::DelegateStudents).to receive(:new).with(user_id: real_user_id).and_return (double(
          get: {statusCode: 200, feed: {}}
        ))
      end
      it_behaves_like 'failed view-as'
    end
  end

end
