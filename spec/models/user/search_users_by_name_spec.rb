describe User::SearchUsersByName do
  let(:name) { nil }
  let(:roles) { [] }
  let(:opts) do
    {
      include_guest_users: true,
      roles: roles
    }
  end
  let(:proxy) { User::SearchUsersByName.new }
  subject { proxy.search_by name, opts }

  shared_examples 'a search with empty input' do
    context 'nil input' do
      it { should be_empty }
    end
    context 'blank input' do
      let(:name) { '    ' }
      it { should be_empty }
    end
    context '\'Mr.\' and nothing else' do
      let(:name) { 'Mr.' }
      it { should be_empty }
    end
  end

  context 'LDAP search' do
    it_should_behave_like 'a search with empty input'

    context 'search all permutations of name' do
      before do
        expect(Net::LDAP::Filter).to receive(:eq).with('displayname', '*man* jo*')
        expect(Net::LDAP::Filter).to receive(:eq).with('displayname', '*jo* man*')
        expect(Net::LDAP).to receive(:new).and_return (ldap = double)
        expect(ldap).to receive(:search).exactly(2).times.and_return []
      end
      context 'discard \'Jr.\'' do
        let(:name) { ' man Jr., jo' }
        it { should be_empty }
      end
      context 'discard \'M.A.\'' do
        let(:name) { 'jo  man M.A.' }
        it { should be_empty }
      end
    end
    context 'filter by role' do
      let(:name) { random_name }
      let(:roles) { [:student, :exStudent] }
      let(:uid) { random_id }
      before {
        # Search should only use LDAP to get UIDs, and then rely on merged attributes to check roles.
        ldap_records = [:faculty, :student, :staff, :exStudent].each_with_index.map do |role, i|
          uid = (i + 1).to_s
          allow(User::AggregatedAttributes).to receive(:new).with(uid).and_return double(get_feed: {ldapUid: uid, roles: { role => true }})
          {ldap_uid: uid}
        end
        allow(CalnetLdap::UserAttributes).to receive(:get_attributes_by_name).with(name, true).and_return ldap_records
      }
      it 'should only match on student-related roles' do
        expect(subject).to have(2).items
        expect(subject[0]).to include(roles: { student: true })
        expect(subject[0][:ldapUid]).to eq '2'
        expect(subject[1]).to include(roles: { exStudent: true })
        expect(subject[1][:ldapUid]).to eq '4'
      end
    end
  end

end
