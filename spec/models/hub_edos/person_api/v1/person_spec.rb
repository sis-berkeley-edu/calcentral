describe HubEdos::PersonApi::V1::Person do
  let(:uid) { random_id }
  let(:user) { double(uid: uid) }

  let(:sis_person_proxy) { double(get: api_response)}
  let(:api_response) do
    {
      statusCode: status_code,
      feed: feed,
    }
  end
  let(:status_code) { 200 }
  let(:identifiers) { [] }
  let(:names) { [] }
  let(:affiliations) { [] }
  let(:emails) { [] }
  let(:feed) do
    {
      identifiers: identifiers,
      names: names,
      affiliations: affiliations,
      emails: emails,
    }
  end

  subject { described_class.new(feed) }

  before do
    allow(HubEdos::PersonApi::V1::SisPerson).to receive(:new).and_return(sis_person_proxy)
  end

  describe '.get' do
    context 'when http api response fails' do
      let(:status_code) { 500 }
      it 'returns nil' do
        expect(described_class.get(user)).to eq nil
      end
    end

    context 'when http api response is successful' do
      let(:status_code) { 200 }
      it 'returns HubEdos::PersonApi::V1::Person object' do
        result = described_class.get(user)
        expect(result).to be_an_instance_of HubEdos::PersonApi::V1::Person
      end
    end
  end
end
