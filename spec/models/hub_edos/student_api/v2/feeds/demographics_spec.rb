describe HubEdos::StudentApi::V2::Feeds::Demographics do
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

    it 'returns feed with ethnicities' do
      result = subject.get
      expect(result[:feed]['ethnicities']).to be
      expect(result[:feed]['ethnicities'].count).to eq 1
      result[:feed]['ethnicities'].each do |ethnicity|
        expect(ethnicity['group']).to be
        expect(ethnicity.has_key?('hispanicLatino')).to eq true
        expect(ethnicity['detail']).to be
      end
    end

    it 'returns feed with usaCountry' do
      result = subject.get
      expect(result[:feed]['usaCountry']).to be
      expect(result[:feed]['usaCountry']['citizenshipStatus']['code']).to eq '1'
      expect(result[:feed]['usaCountry']['citizenshipStatus']['description']).to eq 'Native'
      expect(result[:feed]['usaCountry']['militaryStatus']).to be
      expect(result[:feed]['usaCountry']['visa']['type']['code']).to eq 'J1'
      expect(result[:feed]['usaCountry']['visa']['type']['description']).to eq 'Exchange Visitor Student'
      expect(result[:feed]['usaCountry']['visa']['type']['formalDescription']).to eq 'Exchange visitor student'
      expect(result[:feed]['usaCountry']['visa']['status']).to eq 'G'
    end

    it 'returns feed with residency' do
      result = subject.get
      expect(result[:feed]['residency']).to be
      expect(result[:feed]['residency']['source']).to be
      expect(result[:feed]['residency']['source']['code']).to eq 'Official'
      expect(result[:feed]['residency']['fromTerm']['id']).to eq '2172'
      expect(result[:feed]['residency']['fromTerm']['name']).to eq '2017 Spring'
      expect(result[:feed]['residency']['fromTerm']['academicYear']).to eq '2017'
      expect(result[:feed]['residency']['fromDate']).to eq '2016-01-01'
      expect(result[:feed]['residency']['official']['code']).to eq 'PEND'
      expect(result[:feed]['residency']['official']['description']).to eq 'Pending'
      expect(result[:feed]['residency']['financialAid']['code']).to eq 'NON'
      expect(result[:feed]['residency']['financialAid']['description']).to eq 'Non-Resident'
      expect(result[:feed]['residency']['countryCode']).to eq 'USA'
    end
  end
end
