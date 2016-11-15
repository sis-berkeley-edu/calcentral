describe SearchUsersController do

  let(:id) { '61889' }
  before do
    session['user_id'] = random_id
  end

  describe '#by_id by superuser' do
    let(:is_superuser) { true }
    before do
      auth = User::Auth.new uid: session['user_id'], is_superuser: is_superuser, active: true
      allow(User::Auth).to receive(:where).and_return [ auth ]
    end
    context 'valid id' do
      before do
        allow(User::AggregatedAttributes).to receive(:new).with(id).and_return(double(
          get_feed: {
            ldapUid: id,
            roles: {},
            studentId: '11667051'
          }
        ))
      end
      it 'finds one matching user' do
        get :by_id, id: id
        expect(response).to be_success
        users = JSON.parse(response.body)['users']
        expect(users).to have(1).item
        expect(users[0]['studentId']).to eq '11667051'
        expect(users[0]['ldapUid']).to eq id
        users.each { |user| expect(user).to be_a Hash }
      end
    end
    context 'invalid id' do
      let(:id) { random_id }
      before do
        expect(User::SearchUsers).to receive(:new).with(id: id, except: []).and_return (search = double)
        expect(search).to receive(:search_users).and_return Set.new
      end
      it 'returns empty set' do
        get :by_id, id: id
        expect(response).to be_success
        users = JSON.parse(response.body)['users']
        expect(users).to be_empty
      end
    end
  end

  describe '#by_id by advisor' do
    let(:is_superuser) { false }
    before do
      # Advisor
      expect(User::AggregatedAttributes).to receive(:new).with(session['user_id']).and_return (advisor_proxy = double)
      expect(advisor_proxy).to receive(:get_feed).and_return({ roles: { advisor: is_advisor } })
      # Student
      allow(User::AggregatedAttributes).to receive(:new).with(id).and_return (student_proxy = double)
      allow(student_proxy).to receive(:get_feed).and_return({ roles: { student: is_student } })
    end

    context 'not an advisor' do
      let(:is_advisor) { false }
      let(:is_student) { true }
      it 'should raise exception' do
        get :by_id, id: id
        expect(response.status).to eq 403
        expect(JSON.parse(response.body)['users']).to be_nil
      end
    end
    context 'advisor' do
      let(:is_advisor) { true }
      context 'advisor finds a student' do
        let(:is_student) { true }
        it 'finds one matching user' do
          get :by_id, id: id
          users = JSON.parse(response.body)['users']
          expect(users).to have(1).item
        end
      end
      context 'advisor finds a non-student' do
        let(:is_student) { false }
        it 'should return nothing' do
          get :by_id, id: id
          users = JSON.parse(response.body)['users']
          expect(users).to be_blank
        end
      end
    end
  end

end
