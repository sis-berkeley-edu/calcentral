describe HubEdos::StudentApi::V2::Feeds::Registrations do
  let(:uid) { random_id }
  subject { described_class.new(fake: true, user_id: random_id) }

  context '#get' do
    it 'filters out base attributes' do
      result = subject.get
      expect(result[:statusCode]).to eq 200
      expect(result[:feed].has_key?('names')).to eq false
      expect(result[:feed].has_key?('identifiers')).to eq false
      expect(result[:feed].has_key?('affiliations')).to eq false
      expect(result[:feed].has_key?('confidential')).to eq false
    end

    it 'returns feed with registrations' do
      result = subject.get
      expect(result[:feed]['registrations']).to be
      expect(result[:feed]['registrations'].count).to eq 20
      result[:feed]['registrations'].each do |registration|
        expect(registration['term']).to be
        expect(registration['academicCareer']).to be
        expect(registration.has_key?('eligibleToRegister')).to eq true
        expect(registration['eligibilityStatus']).to be
        expect(registration.has_key?('registered')).to eq true
        expect(registration.has_key?('disabled')).to eq true
        expect(registration.has_key?('athlete')).to eq true
        expect(registration.has_key?('intendsToGraduate')).to eq true
        expect(registration['academicLevels']).to be
        expect(registration['termUnits']).to be
        expect(registration['termGPA']).to be
      end
    end
  end
end
