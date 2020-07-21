describe HubEdos::MyStudent do
  let(:uid) { random_id }
  let(:options) { {} }
  let(:user_attributes) do
    {
      roles: {
        student: is_student,
        applicant: is_applicant,
        releasedAdmit: is_released_admit
      }
    }
  end
  let(:is_student) { false }
  let(:is_applicant) { false }
  let(:is_released_admit) { false }
  let(:sis_person_api_response) do
    {
      statusCode: 200,
      feed: {
        'identifiers' => [],
        'names' => [],
        'affiliations' => [],
        'emails' => [],
      },
      studentNotFound: nil,
    }
  end
  let(:student_api_contacts_response) do
    {
      statusCode: 200,
      feed: {
        'addresses' => [],
        'phones' => [],
        'emails' => [],
      },
      studentNotFound: nil,
    }
  end
  let(:student_api_demographics_response) do
    {
      statusCode: 200,
      feed: {
        'ethnicities' => [],
        'usaCountry' => {},
        'residency' => {},
      },
      studentNotFound: nil,
    }
  end
  let(:student_api_gender_response) do
    {
      statusCode: 200,
      feed: {
        'gender' => {},
      },
      studentNotFound: nil,
    }
  end
  let(:edit_link) do
    {
      editProfile: {
        url: 'https://example.com/EDIT.GBL',
        urlId: 'UC_CX_PROFILE',
      }
    }
  end
  let(:sis_person_proxy) { double(:sis_person_proxy, get: sis_person_api_response)}
  let(:sis_student_contacts_proxy) { double(:sis_student_contact_proxy, get: student_api_contacts_response)}
  let(:sis_student_demographics_proxy) { double(:sis_student_contact_proxy, get: student_api_demographics_response)}
  let(:sis_student_gender_proxy) { double(:sis_student_contact_proxy, get: student_api_gender_response)}
  subject { HubEdos::MyStudent.new(uid, options) }
  before do
    allow(HubEdos::PersonApi::V1::SisPerson).to receive(:new).and_return(sis_person_proxy)
    allow(HubEdos::StudentApi::V2::Feeds::Contacts).to receive(:new).and_return(sis_student_contacts_proxy)
    allow(HubEdos::StudentApi::V2::Feeds::Demographics).to receive(:new).and_return(sis_student_demographics_proxy)
    allow(HubEdos::StudentApi::V2::Feeds::Gender).to receive(:new).and_return(sis_student_gender_proxy)
    MyProfile::EditLink.stub_chain(:new, :get_feed).and_return({:feed => edit_link})
  end

  describe '#get_feed_internal' do
    let(:response) { subject.get_feed_internal }

    it 'should return unfiltered feed' do
      expect(response[:statusCode]).to eq 200
      expect(response[:feed].has_key?('identifiers')).to eq true
      expect(response[:feed].has_key?('names')).to eq true
      expect(response[:feed].has_key?('affiliations')).to eq true
      expect(response[:feed].has_key?('emails')).to eq true
      expect(response[:feed].has_key?('addresses')).to eq true
      expect(response[:feed].has_key?('phones')).to eq true
      expect(response[:feed].has_key?('ethnicities')).to eq true
      expect(response[:feed].has_key?('usaCountry')).to eq true
      expect(response[:feed].has_key?('residency')).to eq true
      expect(response[:feed].has_key?('gender')).to eq true
    end
    context 'view-as session' do
      let(:fields) { %w(affiliations identifiers) }
      let(:options) { { include_fields: fields } }
      it 'should pass include_fields option to proxies' do
        allow(HubEdos::PersonApi::V1::SisPerson).to receive(:new).with({user_id: uid, include_fields: fields}).and_return(sis_person_proxy)
        allow(HubEdos::StudentApi::V2::Feeds::Contacts).to receive(:new).with({user_id: uid, include_fields: fields}).and_return(sis_person_proxy)
        allow(HubEdos::StudentApi::V2::Feeds::Demographics).to receive(:new).with({user_id: uid, include_fields: fields}).and_return(sis_person_proxy)
        allow(HubEdos::StudentApi::V2::Feeds::Gender).to receive(:new).with({user_id: uid, include_fields: fields}).and_return(sis_person_proxy)
        expect(response[:statusCode]).to eq 200
        student = response[:feed]
      end
    end
  end

  describe '#merge_proxy_feeds' do
    let(:feed_hash) do
      {
        statusCode: 200,
        feed: {},
      }
    end
    let(:proxy_options) { {} }
    let(:result) { subject.merge_proxy_feeds(feed_hash, proxy_options) }
    before do
      HubEdos::PersonApi::V1::SisPerson.stub_chain(:new, :get).and_return(sis_person_api_response)
      HubEdos::StudentApi::V2::Feeds::Contacts.stub_chain(:new, :get).and_return(student_api_contacts_response)
      HubEdos::StudentApi::V2::Feeds::Demographics.stub_chain(:new, :get).and_return(student_api_demographics_response)
      HubEdos::StudentApi::V2::Feeds::Gender.stub_chain(:new, :get).and_return(student_api_gender_response)
    end
    context 'when proxy response has an error' do
      let(:student_api_demographics_response) do
        {
          statusCode: 500,
          feed: {},
          errored: true,
        }
      end
      it 'logs error' do
        expected_error_msg = "Got errors in merged student feed on HubEdos::StudentApi::V2::Feeds::Demographics for uid #{uid} with response #{student_api_demographics_response.to_s}"
        expect(subject).to receive_message_chain(:logger, :error).with(expected_error_msg)
        expect(result[:statusCode]).to eq 500
      end
      it 'indicates error in feed' do
        expect(result[:statusCode]).to eq 500
        expect(result[:errored]).to eq true
      end
    end
    context 'when proxy has successful response' do
      it 'merges properties into feed' do
        expect(result[:statusCode]).to eq 200
        expect(result[:errored]).to eq nil
        expect(result[:feed].has_key?('identifiers')).to eq true
        expect(result[:feed].has_key?('names')).to eq true
        expect(result[:feed].has_key?('affiliations')).to eq true
        expect(result[:feed].has_key?('emails')).to eq true
        expect(result[:feed].has_key?('addresses')).to eq true
        expect(result[:feed].has_key?('phones')).to eq true
        expect(result[:feed].has_key?('ethnicities')).to eq true
        expect(result[:feed].has_key?('usaCountry')).to eq true
        expect(result[:feed].has_key?('residency')).to eq true
        expect(result[:feed].has_key?('gender')).to eq true
      end
    end
  end

  describe '#merge_links' do
    let(:feed_hash) { { feed: {} } }
    let(:result) { subject.merge_links(feed_hash) }
    it 'merges profile edit links into feed' do
      expect(result).to be
      expect(feed_hash[:feed][:links][:editProfile][:url]).to eq 'https://example.com/EDIT.GBL'
      expect(feed_hash[:feed][:links][:editProfile][:urlId]).to eq 'UC_CX_PROFILE'
    end
  end

  describe '#instance_key' do
    let(:uid) { '655321' }
    let(:result) { subject.instance_key }
    context 'when user viewing as user' do
      let(:options) { { 'original_user_id' => '665' } }
      it 'returns cache key based on user id and original user id' do
        expect(result).to eq '655321/original_user_id:665'
      end
    end
  end
end
