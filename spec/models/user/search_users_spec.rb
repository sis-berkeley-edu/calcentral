describe User::SearchUsers do

  let(:fake_uid_proxy) { CalnetCrosswalk::ByUid.new }
  let(:fake_cs_id_proxy) { CalnetCrosswalk::ByCsId.new }

  let(:uid_proxy_ldap_uid) { nil }
  let(:cs_id_proxy_ldap_uid) { nil }
  let(:uid) { random_id }
  let(:student_id) { random_id }
  let(:cs_id) { random_cs_id }

  before do
    allow(CalnetCrosswalk::ByUid).to receive(:new).and_return fake_uid_proxy
    allow(CalnetCrosswalk::ByCsId).to receive(:new).and_return fake_cs_id_proxy
    allow(fake_uid_proxy).to receive(:lookup_ldap_uid).and_return uid_proxy_ldap_uid
    allow(fake_cs_id_proxy).to receive(:lookup_ldap_uid).and_return cs_id_proxy_ldap_uid
    allow(User::AggregatedAttributes).to receive(:new).with(uid).and_return double(get_feed: {ldapUid: uid, studentId: student_id, campusSolutionsId: cs_id})
  end
  context 'ByUid returns results' do
    let(:uid_proxy_ldap_uid) { uid }
    it 'should return valid record for valid uid' do
      result = User::SearchUsers.new({:id => random_id}).search_users
      expect(result).to be_an Enumerable
      expect(result).to have(1).item
      expect(result.first[:ldapUid]).to eq uid
      expect(result.first[:studentId]).to eq student_id
      expect(result.first[:campusSolutionsId]).to eq cs_id
    end
  end
  context 'ByCsId returns results' do
    let(:cs_id_proxy_ldap_uid) { uid }
    let(:student_id) { nil }
    it 'should return valid record for valid CS ID' do
      result = User::SearchUsers.new({:id => random_id}).search_users
      expect(result).to have(1).item
      expect(result.first[:ldapUid]).to eq uid
      expect(result.first[:studentId]).to be_nil
      expect(result.first[:campusSolutionsId]).to eq cs_id
    end
  end
  context 'no results from all no proxies' do
    it 'returns no record for invalid id' do
      users = User::SearchUsers.new({:id => '12345'}).search_users
      expect(users).to be_empty
    end
  end
end
