describe User::Profile::Affiliations do
  let(:uid) { '61889' }
  let(:user) { double(:uid => uid) }
  subject { described_class.new(user)}

  let(:ldap_affiliations) { ['STUDENT-TYPE-REGISTERED'] }
  let(:calnet_ldap_person) { double(affiliations: ldap_affiliations) }

  before do
    allow(CalnetLdap::Person).to receive(:get).with(user).and_return(calnet_ldap_person)
  end

  describe 'not_registered?' do
    context 'when student is registered' do
      let(:ldap_affiliations) { ['STUDENT-TYPE-REGISTERED'] }
      it 'returns false' do
        expect(subject.not_registered?).to eq false
      end
    end
    context 'when student is not registered' do
      let(:ldap_affiliations) { ['STUDENT-TYPE-NOT REGISTERED'] }
      it 'returns true' do
        expect(subject.not_registered?).to eq true
      end
    end
  end

  # def not_registered?
  #   ldap_person.affiliations.include? "STUDENT-TYPE-NOT REGISTERED"
  # end
  # def ldap_person
  #   @ldap_person ||= CalnetLdap::Person.get(user)
  # end
end
