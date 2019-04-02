describe User::BasicAttributes do
  let(:attributes) { described_class.attributes_for_uids(uids) }
  before do
    allow(EdoOracle::Queries).to receive(:get_basic_people_attributes).and_return sisedo_oracle_results
    allow(CalnetLdap::UserAttributes).to receive(:get_bulk_attributes).and_return ldap_results
  end

  let(:uids) { %w(2040 61889 211159 242881) }
  let(:sisedo_oracle_results) do
    [
      {
        'affiliations' => 'STUDENT-TYPE-NOT REGISTERED',
        'email_address' => 'oski@berkeley.edu',
        'first_name' => 'Oskillating',
        'last_name' => 'Bear',
        'ldap_uid' => '61889',
        'student_id' => '11667051',
        'person_type' => 'U'
      },
      {
        'affiliations' => 'EMPLOYEE-TYPE-STAFF,STUDENT-STATUS-EXPIRED',
        'email_address' => 'inactive@berkeley.edu',
        'first_name' => 'Aethelred',
        'last_name' => 'the Inactive',
        'ldap_uid' => '242881',
        'student_id' => '10666666',
        'person_type' => 'Z'
      }
    ]
  end
  let(:ldap_results) do
    [
      {
        email_address: 'didi@berkeley.edu',
        first_name: 'Vladimir',
        last_name: 'Heyer',
        ldap_uid: '2040',
        person_name: 'Vladimir Heyer',
        roles: {
          staff: true,
        },
        student_id: '4578329'
      },
      {
        email_address: 'gogo@berkeley.edu',
        first_name: 'Estragon',
        last_name: 'Davis',
        ldap_uid: '211159',
        person_name: 'Estragon Davis',
        roles: {
          staff: true,
        },
        student_id: nil
      }
    ]
  end

  it 'returns an aggregation of Oracle and LDAP records' do
    expect(attributes).to have(4).items
    uids.each do |uid|
      expect(attributes.find { |attr| attr[:ldap_uid] == uid }).to be_present
    end
  end

  it 'calls out to LDAP only for data missing from Oracle' do
    expect(CalnetLdap::UserAttributes).to receive(:get_bulk_attributes).with(%w(2040 211159).to_set).and_return ldap_results
    attributes
  end

  it 'transforms attributes for an active user' do
    oski = attributes.find { |attr| attr[:ldap_uid] == '61889' }
    expect(oski[:first_name]).to eq 'Oskillating'
    expect(oski[:last_name]).to eq 'Bear'
    expect(oski[:email_address]).to eq 'oski@berkeley.edu'
    expect(oski[:student_id]).to eq '11667051'
    expect(oski[:roles][:student]).to eq true
    expect(oski[:roles][:expiredAccount]).to eq false
  end

  it 'transforms attributes for an inactive user' do
    aethelred = attributes.find { |attr| attr[:ldap_uid] == '242881' }
    expect(aethelred[:email_address]).to eq 'inactive@berkeley.edu'
    expect(aethelred[:roles][:expiredAccount]).to eq true
  end

  it 'handles empty arguments' do
    expect(User::BasicAttributes.attributes_for_uids nil).to eq []
    expect(User::BasicAttributes.attributes_for_uids []).to eq []
  end
end
