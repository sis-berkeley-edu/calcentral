describe AdvisorAuthorization do

  let(:filter) { Class.new { extend AdvisorAuthorization } }
  let(:user_id) { random_id }
  let(:current_user) { double real_user_id: random_id, policy: policy }
  let(:is_advisor) { false }
  let(:mock_attributes) do
    { roles: { advisor: is_advisor }}
  end
  before {
    allow(User::AggregatedAttributes).to receive(:new).with(user_id).and_return double(get_feed: {roles: { advisor: is_advisor}})
  }

  describe '#authorize_advisor_view_as' do
    let(:student_uid) { random_id }
    let(:is_student) { false }
    let(:was_student) { false }
    before {
      feed = {
        roles:
          {
            student: is_student,
            exStudent: was_student
          }
      }
      allow(User::AggregatedAttributes).to receive(:new).with(student_uid).and_return double(get_feed: feed)
    }
    subject { filter.authorize_advisor_view_as user_id, student_uid }

    context 'non-advisor looking up student' do
      let(:is_student) { true }
      it 'should fail' do
        expect{ subject }.to raise_error
      end
    end
    context 'advisor looking up non-student' do
      let(:is_advisor) { true }
      it 'should fail' do
        expect{ subject }.to raise_error
      end
    end
    context 'advisor looking up student' do
      let(:is_advisor) { true }
      let(:is_student) { true }
      it 'should pass' do
        expect{ subject }.to_not raise_error
      end
    end
    context 'advisor looking up exStudent' do
      let(:is_advisor) { true }
      let(:was_student) { true }
      it 'should pass' do
        expect{ subject }.to_not raise_error
      end
    end
  end

  describe '#require_advisor' do
    subject { filter.require_advisor user_id }
    context 'ordinary user' do
      it 'should fail' do
        expect{ subject }.to raise_error
      end
    end
    context 'advisor' do
      let(:is_advisor) { true }
      it 'should pass' do
        expect{ subject }.to_not raise_error
      end
    end
  end

end
