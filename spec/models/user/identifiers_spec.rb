describe User::Identifiers do

  class StudentTestClass < BaseProxy; include User::Identifiers; end

  before do
    allow(CalnetLdap::UserAttributes).to receive(:new).with(user_id: uid).and_return double(get_feed: ldap_attributes)
  end

  let(:ldap_attributes) { {ldap_uid: uid, campus_solutions_id: ldap_student_id} }
  let(:uid) { random_id }
  let(:ldap_student_id) { random_id }

  context 'legacy student check' do
    subject { StudentTestClass.new(double(fake: true), user_id: uid).has_legacy_student_data? }
    let(:legacy_id) { '12345678' }
    let(:cs_id) { '9876543210' }
    before do
      allow_any_instance_of(CalnetCrosswalk::ByUid).to receive(:lookup_campus_solutions_id).and_return campus_solutions_id
    end
    context 'ten-digit CS ID' do
      let(:campus_solutions_id) { cs_id }
      it { should be_falsey }
    end
    context 'eight-digit legacy ID' do
      let(:campus_solutions_id) { legacy_id }
      it { should be_truthy }
    end
    context 'Crosswalk disabled' do
      before do
        allow(Settings.calnet_crosswalk_proxy).to receive(:enabled).and_return false
      end
      let(:campus_solutions_id) { nil }
      context 'eight-digit LDAP SID' do
        let(:ldap_student_id) { legacy_id }
        it { should be_truthy }
      end
      context 'ten-digit LDAP SID' do
        let(:ldap_student_id) { cs_id }
        it { should be_falsey }
      end
      context 'SID unavailable' do
        let(:ldap_student_id) { nil }
        it { should be_falsey }
      end
    end
  end

  describe '#lookup_campus_solutions_id' do
    subject { StudentTestClass.new(double(fake: true), user_id: uid).lookup_campus_solutions_id }
    context 'with Crosswalk enabled' do
      let(:cs_id) { random_id }
      before do
        allow(Settings.calnet_crosswalk_proxy).to receive(:enabled).and_return true
        expect(CalnetCrosswalk::ByUid).to receive(:new).with(user_id: uid).and_return(double(
          lookup_campus_solutions_id: cs_id
        ))
        expect(CalnetLdap::UserAttributes).to receive(:new).never
      end
      it { should eq cs_id }
    end
    context 'with Crosswalk disabled' do
      before do
        allow(Settings.calnet_crosswalk_proxy).to receive(:enabled).and_return false
        expect(CalnetCrosswalk::ByUid).to receive(:new).never
      end
      it { should eq ldap_student_id }
    end
  end

  describe '#lookup_ldap_uid' do
    subject { User::Identifiers.lookup_ldap_uid cs_id }
    let(:cs_id) { random_id }
    context 'with Crosswalk enabled' do
      before do
        allow(Settings.calnet_crosswalk_proxy).to receive(:enabled).and_return true
        expect(CalnetCrosswalk::ByCsId).to receive(:new).with(user_id: cs_id).and_return(double(
          lookup_ldap_uid: uid
        ))
        expect(CalnetLdap::UserAttributes).to receive(:new).never
      end
      it { should eq uid }
    end
    context 'with Crosswalk disabled' do
      before do
        allow(Settings.calnet_crosswalk_proxy).to receive(:enabled).and_return false
        expect(CalnetCrosswalk::ByCsId).to receive(:new).never
        allow(CalnetLdap::UserAttributes).to receive(:get_feed_by_cs_id).with(cs_id).and_return ldap_attributes
      end
      it { should eq uid }
    end

    describe '#cache' do
      let(:cs_id) { random_id }
      it 'does not call proxies unnecessarily' do
        expect(CalnetLdap::UserAttributes).to receive(:new).never
        expect(CalnetCrosswalk::ByUid).to receive(:new).never
        expect(CalnetCrosswalk::ByCsId).to receive(:new).never
        User::Identifiers.cache(uid, cs_id)
        expect(User::Identifiers.lookup_ldap_uid cs_id).to eq uid
        expect(User::Identifiers.lookup_campus_solutions_id uid).to eq cs_id
      end
    end

  end

end
