describe CanvasCsv::MaintainUsers do

  let(:known_users) { {} }
  let(:account_changes) { [] }
  subject { CanvasCsv::MaintainUsers.new(known_users, account_changes) }

  describe '#categorize_user_accounts' do
    before { subject.categorize_user_account(existing_account, campus_rows) }

    context 'when email changes' do
      let(:uid) { rand(999999).to_s }
      let(:existing_account) {
        {
          'canvas_user_id' => rand(999999).to_s,
          'user_id' => "UID:#{uid}",
          'login_id' => uid,
          'first_name' => 'Ema',
          'last_name' => 'Ilcha',
          'full_name' => 'Ema Ilcha',
          'email' => 'old@example.edu',
          'status' => 'active'
        }
      }
      let(:campus_rows) { [
        {
          ldap_uid: uid.to_i,
          first_name: 'Ema',
          last_name: 'Ilcha',
          email_address: 'new@example.edu',
          roles: {faculty: true}
        }
      ] }
      it 'finds email change' do
        expect(account_changes.length).to eq(1)
        expect(subject.sis_user_id_changes.length).to eq(0)
        expect(known_users.length).to eq(1)
        new_account = account_changes[0]
        expect(new_account['email']).to eq('new@example.edu')
      end
    end

    context 'when user becomes a student' do
      let(:canvas_user_id) { rand(999999).to_s }
      let(:changed_sis_id_uid) { rand(999999).to_s }
      let(:changed_sis_id_student_id) { rand(999999).to_s }
      let(:existing_account) {
        {
          'canvas_user_id' => canvas_user_id,
          'user_id' => "UID:#{changed_sis_id_uid}",
          'login_id' => changed_sis_id_uid,
          'first_name' => 'Sissy',
          'last_name' => 'Changer',
          'full_name' => 'Sissy Changer',
          'email' => "#{changed_sis_id_uid}@example.edu",
          'status' => 'active'
        }
      }
      let(:campus_rows) { [
        {
          ldap_uid: changed_sis_id_uid.to_i,
          first_name: 'Sissy',
          last_name: 'Changer',
          email_address: "#{changed_sis_id_uid}@example.edu",
          roles: {staff: true, student: true, registered: true},
          student_id: changed_sis_id_student_id.to_i
        }
      ] }
      it 'finds SIS ID change' do
        expect(account_changes.length).to eq 0
        expect(subject.sis_user_id_changes.length).to eq 1
        expect(known_users.length).to eq 1
        expect(subject.sis_user_id_changes["sis_login_id:#{changed_sis_id_uid}"]['new_id']).to eq changed_sis_id_student_id
      end
    end

    context 'when there are no changes' do
      let(:uid) { rand(999999).to_s }
      let(:existing_account) {
        {
          'canvas_user_id' => rand(999999).to_s,
          'user_id' => "UID:#{uid}",
          'login_id' => uid,
          'first_name' => 'Noam',
          'last_name' => 'Changey',
          'full_name' => 'Noam Changey',
          'email' => "#{uid}@example.edu",
          'status' => 'active'
        }
      }
      let(:campus_rows) { [
        {
          ldap_uid: uid.to_i,
          first_name: 'Noam',
          last_name: 'Changey',
          email_address: "#{uid}@example.edu",
          roles: {staff: true, exStudent: true},
          student_id: 9999999
        }
      ] }
      it 'just notes the UID' do
        expect(account_changes.length).to eq(0)
        expect(subject.sis_user_id_changes.length).to eq(0)
        expect(known_users.length).to eq(1)
        expect(known_users[uid.to_s]).to eq "UID:#{uid}"
      end
    end

    context 'when Canvas full_name matches campus first_name and last_name but Canvas first_name does not match campus first_name' do
      let(:uid) { rand(999999).to_s }
      let(:existing_account) {
        {
          'canvas_user_id' => rand(999999).to_s,
          'user_id' => "UID:#{uid}",
          'login_id' => uid,
          'first_name' => 'Eugene',
          'last_name' => 'Debs',
          'full_name' => 'Eugene V Debs',
          'email' => "#{uid}@example.edu",
          'status' => 'active'
        }
      }
      let(:campus_rows) { [
        {
          ldap_uid: uid.to_i,
          first_name: 'Eugene V',
          last_name: 'Debs',
          email_address: "#{uid}@example.edu",
          roles: {staff: true, exStudent: true},
          student_id: 9999999
        }
      ] }
      it 'considers the account to be unchanged' do
        expect(account_changes.length).to eq(0)
        expect(subject.sis_user_id_changes.length).to eq(0)
      end
      it 'updates known users hash' do
        expect(known_users.length).to eq(1)
        expect(known_users[uid.to_s]).to eq "UID:#{uid}"
      end
    end

    context 'when Canvas has a non-LDAP account' do
      let(:uid) { 'some_special_admin_account' }
      let(:existing_account) {
        {
          'canvas_user_id' => rand(999999).to_s,
          'user_id' => uid,
          'login_id' => uid,
          'first_name' => 'Uneeda',
          'last_name' => 'Integer',
          'full_name' => 'Uneeda Integer',
          'email' => "#{uid}@example.edu",
          'status' => 'active'
        }
      }
      let(:campus_rows) { [
        {
          ldap_uid: 0,
          first_name: 'Sumotha',
          last_name: 'Match',
          email_address: 'zero@example.edu',
          roles: {student: true, registered: true},
          student_id: 9999999
        }
      ] }
      it 'skips the record' do
        expect(account_changes.length).to eq(0)
        expect(subject.sis_user_id_changes.length).to eq(0)
        expect(known_users.length).to eq(0)
      end
    end

    context 'when an inactivated user account reappears in campus systems' do
      let(:uid) { random_id }
      let(:student_id) { random_id }
      let(:canvas_user_id) { random_id }
      let(:existing_account) {
        {
          'canvas_user_id' => canvas_user_id,
          'user_id' => "UID:#{uid}",
          'login_id' => "inactive-#{uid}",
          'first_name' => 'Skip',
          'last_name' => 'James',
          'full_name' => 'Skip James',
          'email' => nil,
          'status' => 'active'
        }
      }
      let(:campus_rows) { [
        {
          ldap_uid: uid.to_i,
          first_name: 'Skip',
          last_name: 'James',
          email_address: "#{uid}@example.edu",
          roles: {student: true, registered: true},
          student_id: student_id
        }
      ] }
      it 'reactivates the user account' do
        expect(account_changes.length).to eq(1)
        expect(account_changes[0]['login_id']).to eq uid
        expect(account_changes[0]['user_id']).to eq student_id
        expect(account_changes[0]['email']).to eq "#{uid}@example.edu"
        expect(subject.sis_user_id_changes).to eq({"sis_login_id:inactive-#{uid}" => {
          'old_id' => "UID:#{uid}",
          'new_id' => student_id
        }})
        expect(subject.user_email_deletions).to be_blank
      end
      it 'updates known users hash' do
        expect(known_users.length).to eq(1)
        expect(known_users[uid.to_s]).to eq student_id
      end
    end
  end

  context 'when a user account no longer appears in the campus DB' do
    let(:uid) { random_id }
    let(:student_id) { random_id }
    let(:canvas_user_id) { random_id }
    let(:existing_account) {
      {
        'canvas_user_id' => canvas_user_id,
        'user_id' => student_id,
        'login_id' => uid,
        'first_name' => 'Syd',
        'last_name' => 'Barrett',
        'full_name' => 'Syd Barrett',
        'email' => "#{uid}@example.edu",
        'status' => 'active'
      }
    }
    let(:campus_rows) { [] }
    let(:ldap_record) { nil }
    before do
      allow(Settings.canvas_proxy).to receive(:inactivate_expired_users).and_return(inactivate_expired_users)
      allow_any_instance_of(CalnetLdap::Client).to receive(:search_by_uid).with(uid.to_i).and_return(ldap_record)
      subject.categorize_user_account(existing_account, campus_rows)
    end
    context 'when the campus DB account is marked as having no active CalNet account' do
      let(:campus_rows) { [
        {
          ldap_uid: uid.to_i,
          first_name: 'Syd',
          last_name: 'Barrett',
          email_address: "#{uid}@example.edu",
          roles: {student: true, registered: true, expiredAccount: true},
          student_id: student_id,
        }
      ] }
      let(:inactivate_expired_users) { true }
      it 'deactivates the user account' do
        expect(account_changes.length).to eq 1
        expect(account_changes[0]['login_id']).to eq "inactive-#{uid}"
        expect(account_changes[0]['user_id']).to eq "UID:#{uid}"
        expect(account_changes[0]['email']).to be_blank
        expect(subject.sis_user_id_changes).to eq({"sis_login_id:#{uid}" => {
          'old_id' => student_id,
          'new_id' => "UID:#{uid}"}})
        expect(known_users.length).to eq 1
        expect(subject.user_email_deletions).to eq [canvas_user_id]
      end
      it 'updates known users hash' do
        expect(known_users[uid.to_s]).to eq "UID:#{uid}"
      end
    end
    context 'when we can trust campus data sources' do
      let(:inactivate_expired_users) { true }
      it 'deactivates the user account' do
        expect(account_changes.length).to eq 1
        expect(account_changes[0]['login_id']).to eq "inactive-#{uid}"
        expect(account_changes[0]['user_id']).to eq "UID:#{uid}"
        expect(account_changes[0]['email']).to be_blank
        expect(subject.sis_user_id_changes).to eq({"sis_login_id:#{uid}" => {
          'old_id' => student_id,
          'new_id' => "UID:#{uid}"}})
        expect(known_users.length).to eq 1
        expect(subject.user_email_deletions).to eq [canvas_user_id]
      end
    end
    context 'when we cannot trust campus data sources' do
      let(:inactivate_expired_users) { false }
      it 'does nothing' do
        expect(account_changes.length).to eq 0
        expect(subject.sis_user_id_changes).to eq({})
        expect(subject.user_email_deletions).to eq []
      end
      it 'updates known users hash with existing login id' do
        expect(known_users[uid.to_s]).to eq student_id
      end
    end
  end

  describe '#derive_sis_user_id' do
    let(:uid) { rand(999999).to_s }
    let(:student_id) { rand(999999).to_s }
    let(:derived_id) { subject.derive_sis_user_id(ldap_uid: uid, student_id: student_id, roles: roles) }
    context 'when an ex-student' do
      let(:roles) { {exStudent: true} }
      it 'uses the LDAP UID' do
        expect(derived_id).to eq "UID:#{uid}"
      end
    end
    context 'when a student employee' do
      let(:roles) { {student: true, registered: true, faculty: true} }
      it 'uses the student ID' do
        expect(derived_id).to eq student_id
      end
    end
    context 'when a student with registration issues' do
      let(:roles) { {staff: true, student: true, registered: false} }
      it 'uses the student ID' do
        expect(derived_id).to eq student_id
      end
    end
    context 'when missing a student ID' do
      let(:roles) { {student: true, registered: true} }
      let(:student_id) { nil }
      it 'uses the LDAP UID' do
        expect(derived_id).to eq "UID:#{uid}"
      end
    end
    context 'when fancy SIS user IDs are disabled' do
      before { allow(Settings.canvas_proxy).to receive(:mixed_sis_user_id).and_return nil }
      let(:roles) { {student: true, registered: true} }
      it 'uses the LDAP UID for everyone' do
        expect(derived_id).to eq uid
      end
    end
    context 'when a concurrent enrollment student' do
      let(:roles) { {concurrentEnrollmentStudent: true} }
      it 'uses the student ID' do
        expect(derived_id).to eq student_id
      end
    end
  end

  describe '#change_sis_user_ids_by_api' do
    before do
      subject.sis_user_id_changes = {
        'sis_login_id:1084726' => {'old_id' => 'UID:1084726', 'new_id' => '289021'},
        'sis_login_id:1084727' => {'old_id' => '91084727', 'new_id' => 'UID:289022'},
        'sis_login_id:1084728' => {'old_id' => '91084728', 'new_id' => 'UID:289023'},
      }
    end
    it 'sends call to change each sis user id update' do
      expect(CanvasCsv::MaintainUsers).to receive(:change_sis_user_id).with('sis_login_id:1084726', '289021').ordered
      expect(CanvasCsv::MaintainUsers).to receive(:change_sis_user_id).with('sis_login_id:1084727', 'UID:289022').ordered
      expect(CanvasCsv::MaintainUsers).to receive(:change_sis_user_id).with('sis_login_id:1084728', 'UID:289023').ordered
      subject.change_sis_user_ids_by_api
    end
    context 'in dry-run mode' do
      before do
        allow(Settings.canvas_proxy).to receive(:dry_run_import).and_return('anything')
      end
      it 'does not tell Canvas to change the sis_user_ids' do
        expect(CanvasCsv::MaintainUsers).to receive(:change_sis_user_id).never
        subject.change_sis_user_ids_by_api
      end
    end
  end

  describe '#change_sis_user_id' do
    let(:canvas_user_id) { rand(999999) }
    let(:ldap_uid) { rand(999999) }
    let(:new_sis_id) { "UID:#{rand(99999)}" }
    let(:old_sis_id) { rand(99999).to_s }
    let(:login_object_id) { rand(999999) }

    shared_examples 'successful change' do
      it 'calls the API to change the ID' do
        canvas_logins_response = {
          statusCode: 200,
          body: [
            {
              'account_id' => 90242,
              'id' => login_object_id,
              'sis_user_id' => old_sis_id,
              'unique_id' => matching_login_id,
              'user_id' => canvas_user_id
            },
            {
              'account_id' => 90242,
              'id' => rand(99999),
              'sis_user_id' => nil,
              'unique_id' => "test-#{rand(99999)}",
              'user_id' => canvas_user_id
            }
          ]
        }
        fake_logins_proxy = double()
        expect(fake_logins_proxy).to receive(:user_logins).with(canvas_user_id).and_return canvas_logins_response
        expect(fake_logins_proxy).to receive(:change_sis_user_id).with(login_object_id, new_sis_id).and_return(statusCode: 200)
        allow(Canvas::Logins).to receive(:new).and_return fake_logins_proxy
        CanvasCsv::MaintainUsers.change_sis_user_id(canvas_user_id, new_sis_id)
      end
    end

    context 'active user account' do
      let(:matching_login_id) { ldap_uid.to_s }
      include_examples 'successful change'
    end
    context 'before reactivating an inactivated account' do
      let(:matching_login_id) { "inactive-#{ldap_uid}" }
      include_examples 'successful change'
    end
  end

  describe '#handle_email_deletions' do
    let(:uid) { random_id }
    let(:channel_id) { random_id.to_i }
    let(:canvas_user_id) { random_id.to_i }
    let(:fake_channels) do
      instance_double(Canvas::CommunicationChannels, list: {
        statusCode: 200,
        body: [{
          'id' => channel_id,
          'position' => 1,
          'user_id' => canvas_user_id,
          'workflow_state' => 'active',
          'address' => "#{uid}@example.edu",
          'type' => 'email'
        }]}
      )
    end
    before do
      expect(Canvas::CommunicationChannels).to receive(:new).with(canvas_user_id: canvas_user_id).and_return fake_channels
    end
    context 'in live mode' do
      before do
        allow(Settings.canvas_proxy).to receive(:dry_run_import).and_return(nil)
      end
      it 'finds and deletes all email addresses' do
        expect(fake_channels).to receive(:delete).with(channel_id).and_return({
          statusCode: 200,
          body: [{
            'id' => channel_id,
            'position' => 1,
            'user_id' => canvas_user_id,
            'workflow_state' => 'retired',
            'address' => "#{uid}@example.edu",
            'type' => 'email'
          }]
        })
        subject.handle_email_deletions [canvas_user_id]
      end
    end
    context 'in dry-run mode' do
      before do
        allow(Settings.canvas_proxy).to receive(:dry_run_import).and_return(true)
      end
      it 'does not tell Canvas to change the sis_user_ids' do
        expect(fake_channels).to receive(:delete).never
        subject.handle_email_deletions [canvas_user_id]
      end
    end
  end

  describe '#provisioned_account_eq_sis_account?' do
    let(:non_name_fields) do
      {
        'login_id' => '123',
        'email' => 'jrjr@example.com'
      }
    end
    let(:provisioned_account) do
      non_name_fields.merge({
        'first_name' => 'Emmanuel',
        'last_name' => 'Tommaso',
        'full_name' => 'Emmanuel V Tommaso',
        'sortable_name' => 'Tommaso, Emmanuel V'
      })
    end
    let(:sis_account) do
      non_name_fields.merge({
        'first_name' => 'Emmanuel V',
        'last_name' => 'Tommaso'
      })
    end
    subject {CanvasCsv::MaintainUsers.provisioned_account_eq_sis_account?(provisioned_account, sis_account)}

    context 'when accounts are identical' do
      it {should be_truthy}
    end

    context 'when username checks are enabled' do
      before do
        allow(Settings.canvas_proxy).to receive(:maintain_user_names).and_return(true)
      end
      context 'when the full names match' do
        it {should be_truthy}
      end
      context 'when the user dropped the ambiguous initial' do
        let(:sis_account) { non_name_fields.merge({'first_name' => 'Emmanuel', 'last_name' => 'Tommaso'}) }
        it {should be_falsey}
      end
      context 'with embedded commas' do
        let(:provisioned_account) { non_name_fields.merge({
            'first_name' => 'Jr. Emmanuel', 'last_name' => 'Tommaso',
            'full_name' => 'Emmanuel Tommaso, Jr.',
            'sortable_name' => 'Tommaso, Jr., Emmanuel'
          }) }
        let(:sis_account) { non_name_fields.merge({'first_name' => 'Emmanuel', 'last_name' => 'Tommaso, Jr.'}) }
        it {should be_truthy}
      end
      context 'with really determined credentialing' do
        let(:provisioned_account) { non_name_fields.merge({
            'first_name' => 'Ph.D., J.D., Emmanuel', 'last_name' => 'Tommaso',
            'full_name' => 'Emmanuel Tommaso, Ph.D., J.D.',
            'sortable_name' => 'Tommaso, Ph.D., J.D., Emmanuel'
          }) }
        let(:sis_account) { non_name_fields.merge({'first_name' => 'Emmanuel', 'last_name' => 'Tommaso, Ph.D., J.D.'}) }
        it {should be_truthy}
      end
    end

    context 'when username checks are disabled' do
      before do
        allow(Settings.canvas_proxy).to receive(:maintain_user_names).and_return(false)
      end
      context 'when all that differs is the name' do
        let(:sis_account) { provisioned_account.merge({'first_name' => 'Jake', 'full_name' => 'Jake Smythe'}) }
        it {should be_truthy}
      end
      context 'when the email address changes' do
        let(:sis_account) { provisioned_account.merge({'email' => 'js@example.com'}) }
        it {should be_falsey}
      end
      context 'when the email column is empty' do
        let(:sis_account) { provisioned_account.merge({'email' => nil}) }
        it {should be_truthy}
      end
    end

  end

  describe '#parse_login_id' do
    let(:uid) { random_id }
    it 'understands an inactive ID' do
      parsed = CanvasCsv::MaintainUsers.parse_login_id "inactive-#{uid}"
      expect(parsed[:ldap_uid]).to eq uid.to_i
      expect(parsed[:inactive_account]).to be_truthy
    end
    it 'understands an active ID' do
      parsed = CanvasCsv::MaintainUsers.parse_login_id uid
      expect(parsed[:ldap_uid]).to eq uid.to_i
      expect(parsed[:inactive_account]).to be_falsey
    end
    it 'does not even try to deal with anything else' do
      parsed = CanvasCsv::MaintainUsers.parse_login_id 'forgetit'
      expect(parsed[:ldap_uid]).to be_nil
      expect(parsed[:inactive_account]).to be_falsey
    end
  end

end
