describe CalnetLdap::Person do
  let(:uid) { '61889' }
  let(:user) { double(uid: uid) }
  let(:berkeleyedustuid) { ['123456789'] }
  let(:berkeleyeducsid) { ['123456789'] }
  let(:givenname) { ['Michael G.'] }
  let(:displayname) { ['Michael G. Scott'] }
  let(:sn) { ['Scott'] }
  let(:cn) { ['Scott, Michael G.'] }
  let(:mail) { ['michaelscarn@berkeley.edu'] }
  let(:berkeleyeduofficialemail) { ['michaelscott@berkeley.edu'] }
  let(:berkeleyeduaffiliations) do
    [
      'AFFILIATE-TYPE-ADVCON-ATTENDEE',
      'AFFILIATE-TYPE-ADVCON-STUDENT',
      'STUDENT-TYPE-REGISTERED'
    ]
  end
  let(:berkeleyeduismemberof) do
    [
      'cn=edu:berkeley:official:all-accounts,ou=campus groups,dc=berkeley,dc=edu',
      'cn=edu:berkeley:official:students:undergraduate-students,ou=campus groups,dc=berkeley,dc=edu',
    ]
  end
  let(:berkeleyeduconfidentialflag) { ['false'] }
  let(:berkeleyeduemailrelflag) { ['false'] }
  let(:net_ldap_entry) do
    net_ldap_entry = double(Net::LDAP::Entry,
      attribute_names: [
        :uid,
        :cn,
        :sn,
        :mail,
        :givenname,
        :displayname,
        :berkeleyedustuid,
        :berkeleyeducsid,
        :berkeleyeduaffiliations,
        :berkeleyeduofficialemail,
        :berkeleyeduconfidentialflag,
        :berkeleyeduemailrelflag,
        :berkeleyeduismemberof,
      ]
    )
    allow(net_ldap_entry).to receive(:[]).with(:uid).and_return([uid])
    allow(net_ldap_entry).to receive(:[]).with(:cn).and_return(cn)
    allow(net_ldap_entry).to receive(:[]).with(:sn).and_return(sn)
    allow(net_ldap_entry).to receive(:[]).with(:mail).and_return(mail)
    allow(net_ldap_entry).to receive(:[]).with(:givenname).and_return(givenname)
    allow(net_ldap_entry).to receive(:[]).with(:displayname).and_return(displayname)
    allow(net_ldap_entry).to receive(:[]).with(:berkeleyedustuid).and_return(berkeleyedustuid)
    allow(net_ldap_entry).to receive(:[]).with(:berkeleyeducsid).and_return(berkeleyeducsid)
    allow(net_ldap_entry).to receive(:[]).with(:berkeleyeduofficialemail).and_return(berkeleyeduofficialemail)
    allow(net_ldap_entry).to receive(:[]).with(:berkeleyeduaffiliations).and_return(berkeleyeduaffiliations)
    allow(net_ldap_entry).to receive(:[]).with(:berkeleyeduismemberof).and_return(berkeleyeduismemberof)
    allow(net_ldap_entry).to receive(:[]).with(:berkeleyeduconfidentialflag).and_return(berkeleyeduconfidentialflag)
    allow(net_ldap_entry).to receive(:[]).with(:berkeleyeduemailrelflag).and_return(berkeleyeduemailrelflag)
    net_ldap_entry
  end

  let(:ldap_client) { double(:search_by_uid => net_ldap_entry) }
  before { allow(CalnetLdap::Client).to receive(:new).and_return(ldap_client) }

  describe '.get' do
    let(:result) { result = described_class.get(user) }
    it 'returns loaded calnet ldap person object' do
      expect(result).to be_an_instance_of described_class
      expect(result.uid).to eq '61889'
      expect(result.student_id).to eq '123456789'
      expect(result.campus_solutions_id).to eq '123456789'
      expect(result.email).to eq 'michaelscarn@berkeley.edu'
      expect(result.given_name).to eq 'Michael G.'
      expect(result.common_name).to eq 'Scott, Michael G.'
      expect(result.surname).to eq 'Scott'
      expect(result.display_name).to eq 'Michael G. Scott'
      expect(result.official_email).to eq 'michaelscott@berkeley.edu'
      expect(result.confidential_flag).to eq false
      expect(result.affiliations).to eq ["AFFILIATE-TYPE-ADVCON-ATTENDEE", "AFFILIATE-TYPE-ADVCON-STUDENT", "STUDENT-TYPE-REGISTERED"]
    end

    context 'when confidential flag is true' do
      let(:berkeleyeduconfidentialflag) { ['true'] }
      it 'returns true value' do
        expect(result.confidential_flag).to eq true
      end
    end
  end
end
