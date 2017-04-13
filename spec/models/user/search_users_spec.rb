describe User::SearchUsers do

  let(:uid) { random_id }
  let(:student_id) { random_id }
  let(:cs_id) { random_cs_id }
  let(:invalid_id) { random_id }

  before do
    allow(CalnetCrosswalk::ByCsId).to receive(:new).with(user_id: cs_id).and_return double(lookup_ldap_uid: uid)
    allow(CalnetCrosswalk::ByCsId).to receive(:new).with(user_id: uid).and_return double(lookup_ldap_uid: nil)
    allow(CalnetCrosswalk::ByCsId).to receive(:new).with(user_id: invalid_id).and_return double(lookup_ldap_uid: nil)
    allow(User::AggregatedAttributes).to receive(:new).with(uid).and_return double(get_feed: {ldapUid: uid, studentId: student_id, campusSolutionsId: cs_id})
    allow(User::AggregatedAttributes).to receive(:new).with(cs_id).and_return double(get_feed: {unknown: true})
    allow(User::AggregatedAttributes).to receive(:new).with(invalid_id).and_return double(get_feed: {unknown: true})
  end
  context 'ByUid returns results' do
    it 'should return valid record for valid uid' do
      result = User::SearchUsers.new({:id => uid}).search_users
      expect(result).to be_an Enumerable
      expect(result).to have(1).item
      expect(result.first[:ldapUid]).to eq uid
      expect(result.first[:studentId]).to eq student_id
      expect(result.first[:campusSolutionsId]).to eq cs_id
    end
  end
  context 'ByCsId returns results' do
    let(:student_id) { nil }
    it 'should return valid record for valid CS ID' do
      result = User::SearchUsers.new({:id => cs_id}).search_users
      expect(result).to have(1).item
      expect(result.first[:ldapUid]).to eq uid
      expect(result.first[:studentId]).to be_nil
      expect(result.first[:campusSolutionsId]).to eq cs_id
    end
  end
  context 'no results from all no proxies' do
    it 'returns no record for invalid id' do
      users = User::SearchUsers.new({:id => invalid_id}).search_users
      expect(users).to be_empty
    end
  end
end
