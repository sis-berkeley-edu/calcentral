describe ViewAsAuthorization do

  let(:filter) { Class.new { extend ViewAsAuthorization } }
  let(:can_view_as) { false }
  let(:directly_authenticated) { true }
  let(:policy) { double(can_view_as?: can_view_as) }
  let(:current_user) { double user_id: random_id, policy: policy, directly_authenticated?: directly_authenticated }
  let(:is_advisor) { false }
  before {
    allow(User::AggregatedAttributes).to receive(:new).with(current_user.user_id).and_return double get_feed: { roles: { advisor: is_advisor } }
  }

  describe '#authorize_query_stored_users' do
    subject { filter.authorize_query_stored_users current_user }
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
    context 'super-user' do
      let(:can_view_as) { true }
      it 'should pass' do
        expect{ subject }.to_not raise_error
      end
      context 'when already viewing-as' do
        let(:directly_authenticated) { false }
        it 'should fail' do
          expect{ subject }.to raise_error
        end
      end
    end
  end

end
