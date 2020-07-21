# encoding: UTF-8
describe HubEdos::UserAttributes do

  let(:user_id) { '61889' }
  let(:users_campus_solutions_id) { '11667051' }
  before { allow(subject).to receive(:lookup_campus_solutions_id).and_return(users_campus_solutions_id) }

  let(:fake_person_proxy) { HubEdos::PersonApi::V1::SisPerson.new(fake: true, user_id: user_id) }
  before { allow(HubEdos::PersonApi::V1::SisPerson).to receive(:new).and_return(fake_person_proxy) }

  let(:fake_student_attributes_proxy) { HubEdos::StudentApi::V2::Feeds::StudentAttributes.new(fake: true, user_id: user_id) }
  before { allow(HubEdos::StudentApi::V2::Feeds::StudentAttributes).to receive(:new).and_return(fake_student_attributes_proxy) }

  subject { HubEdos::UserAttributes.new(user_id: user_id) }
  let(:feed) { subject.get }

  context '#get' do
    it 'should provide the converted person data structure' do
      expect(feed[:ldap_uid]).to eq user_id
      expect(feed[:campus_solutions_id]).to eq users_campus_solutions_id
      expect(feed[:student_id]).to eq users_campus_solutions_id
      expect(feed[:given_name]).to eq 'Oski'
      expect(feed[:family_name]).to eq 'Bear'
      expect(feed[:first_name]).to eq 'Ziggy'
      expect(feed[:last_name]).to eq 'Stardust'
      expect(feed[:person_name]).to eq 'Ziggy  Stardust'
      expect(feed[:email_address]).to eq 'oski@gmail.com'
      expect(feed[:official_bmail_address]).to eq 'oski@berkeley.edu'
      expect(feed[:roles]).to include(:applicant => true, :releasedAdmit => true)
    end
  end

  describe '#extract_roles' do
    let(:person_feed) do
      {
        identifiers: identifiers,
        affiliations: affiliations,
      }
    end
    let(:identifiers) { [] }
    let(:affiliations) { [] }
    let(:confidential_student) { false }
    let(:result) { {} }
    let(:student_attributes) do
      {
        studentAttributes: [],
        confidential: confidential_student
      }
    end
    before do
      allow(subject).to receive(:get_student_attributes).and_return(student_attributes)
      subject.get_ids(result)
      subject.extract_roles(person_feed, result)
    end
    context 'student attributes returns empty feed' do
      let(:student_attributes) { {} }
      it 'omits confidential boolean value' do
        expect(result[:roles].has_key?(:confidential)).to eq false
      end
    end
    context 'user has a campus solutions id' do
      let(:identifiers) do
        [{'id' => users_campus_solutions_id, 'type' => 'student-id'}]
      end
      context 'user does not have a student affiliaton' do
        let(:affiliations) { [{type: {code: 'EMPLOYEE'}, status: {code: 'ACT'}}] }
        it 'does not set a student_id' do
          subject.extract_roles(person_feed, result)
          expect(result[:student_id]).to eq nil
        end
      end
      context 'user has a student affiliaton' do
        let(:affiliations) do
          [
            {type: {code: 'STUDENT'}, status: {code: 'ACT'}},
            {type: {code: 'UNDERGRAD'}, status: {code: 'ACT'}}
          ]
        end
        it 'does set student_id' do
          expect(result[:student_id]).to eq result[:campus_solutions_id]
        end
        context 'without confidential flag' do
          let(:confidential_student) { false }
          it 'does not set a confidential role' do
            expect(result[:roles].keys).not_to include(:confidential)
          end
        end
        context 'with confidential flag' do
          let(:confidential_student) { true }
          it 'includes a confidential role' do
            expect(result[:roles][:confidential]).to eq true
          end
        end
      end
    end
  end

  context 'unexpected errors from Hub calls' do
    before do
      allow_any_instance_of(HubEdos::PersonApi::V1::SisPerson).to receive(:get_internal).and_return({'non' => 'sense'})
    end
    it 'returns from errors' do
      expect(feed).to eq({
        body: 'An unknown server error occurred',
        statusCode: 503
      })
    end
  end

  it 'delegates role parsing' do
    expect_any_instance_of(Berkeley::UserRoles).to receive(:roles_from_cs_affiliations).and_return(
      {
        chancellor: true,
        graduate: true
      }
    )
    expect(feed[:roles]).to eq({chancellor: true, graduate: true})
  end

  describe '#get_sis_person' do
    context 'when sis person data returned by api' do
      it 'returns symbolized hash without person wrapper' do
        result = subject.get_sis_person
        expect(result.has_key?('identifiers')).to eq false
        expect(result.has_key?('names')).to eq false
        expect(result.has_key?('affiliations')).to eq false
        expect(result.has_key?('emails')).to eq false
        expect(result.keys).to eq [:identifiers, :names, :affiliations, :emails]
        expect(result[:names][0][:formattedName]).to eq 'Ziggy  Stardust'
        expect(result[:affiliations][0][:type][:code]).to eq 'ADMT_UX'
        expect(result[:emails][0][:type][:code]).to eq 'CAMP'
      end
    end
    context 'when sis person data not returned by api' do
      before { allow_any_instance_of(HubEdos::PersonApi::V1::SisPerson).to receive(:get).and_return nil }
      it 'returns nil' do
        result = subject.get_sis_person
        expect(result).to eq nil
      end
    end
  end

  describe '#get_student_attributes' do
    let(:result) { subject.get_student_attributes }
    context 'when student attributes returned by api' do
      it 'provides student attributes' do
        expect(result[:studentAttributes].count).to eq 21
      end
      it 'provides confidential boolean' do
        expect(result[:confidential]).to eq false
      end
    end
    context 'when api returns 404 error' do
      let(:error_404_response) { {statusCode: 404, feed: {}, studentNotFound: true} }
      before { allow_any_instance_of(HubEdos::StudentApi::V2::Feeds::StudentAttributes).to receive(:get).and_return(error_404_response) }
      it 'logs error' do
        logger_object = double(:logger)
        expect(logger_object).to receive(:warn).with("Student Attributes request failed for UID #{user_id}")
        expect(subject).to receive(:logger).and_return(logger_object)
        expect(result).to eq({})
      end
      it 'returns empty feed object' do
        expect(result[:studentAttributes]).to eq nil
        expect(result[:confidential]).to eq nil
      end
    end
  end

  describe '#identifiers_check' do
    let(:person_feed) do
      {
        identifiers: person_feed_identifiers
      }
    end
    let(:person_feed_identifiers) { [] }
    context 'when identifiers are not present' do
      it 'logs error' do
        # emulating CS ID being set
        subject.instance_eval { @campus_solutions_id = '11667051' }
        stubbed_logger = double(:logger)
        expected_logger_message = "No 'identifiers' found in CS attributes {:identifiers=>[]} for UID #{user_id}, CS ID #{users_campus_solutions_id}"
        expect(stubbed_logger).to receive(:error).with(expected_logger_message).and_return(nil)
        expect(subject).to receive(:logger).and_return(stubbed_logger)
        result = subject.identifiers_check(person_feed)
      end
    end
    context 'when identifiers are present' do
      context 'when student-id identifier not present' do
        let(:person_feed_identifiers) { [{type: 'campus-uid', id: user_id, disclose: false}] }
        it 'logs error' do
          subject.instance_eval { @campus_solutions_id = '11667051' }
          stubbed_logger = double(:logger)
          expected_logger_message = "No 'student-id' found in CS Identifiers [{:type=>\"campus-uid\", :id=>\"#{user_id}\", :disclose=>false}] for UID #{user_id}, CS ID #{users_campus_solutions_id}"
          expect(stubbed_logger).to receive(:error).with(expected_logger_message).and_return(nil)
          expect(subject).to receive(:logger).and_return(stubbed_logger)
          result = subject.identifiers_check(person_feed)
        end
      end
      context 'when student-id identifier is present' do
        let(:student_id) { users_campus_solutions_id }
        let(:person_feed_identifiers) do
          [
            {type: 'campus-uid', id: user_id, disclose: false},
            {type: 'student-id', id: student_id, disclose: false},
          ]
        end
        context 'when student-id does not match campus solutions id' do
          let(:student_id) { '123456' }
          it 'logs error' do
            subject.instance_eval { @campus_solutions_id = '11667051' }
            stubbed_logger = double(:logger)
            expected_logger_message = "Got student-id 123456 from CS Identifiers but CS ID #{users_campus_solutions_id} from Crosswalk for UID #{user_id}"
            expect(stubbed_logger).to receive(:error).with(expected_logger_message).and_return(nil)
            expect(subject).to receive(:logger).and_return(stubbed_logger)
            result = subject.identifiers_check(person_feed)
          end
        end
      end
    end
  end

  describe '#find_name' do
    let(:preferred_name) do
      {
        type: {
          code: 'PRF',
          description: 'Preferred'
        },
        familyName: 'Stardust',
        givenName: 'Ziggy',
        formattedName: 'Ziggy  Stardust',
      }
    end
    let(:primary_name) do
      {
        type: {
          code: 'PRI',
          description: 'Primary'
        },
        familyName: 'Bear',
        givenName: 'Oski',
        formattedName: 'Oski  Bear',
      }
    end
    let(:type) { 'FOO' }
    let(:result) { {} }
    let(:name) { subject.find_name(type, person_feed, result) }
    context 'when names not present' do
      let(:person_feed) { {} }
      it 'returns false' do
        expect(name).to eq false
      end
    end
    context 'when names empty' do
      let(:person_feed) { {:names=>[]} }
      it 'returns false' do
        expect(name).to eq false
      end
    end
    context 'when names present' do
      let(:person_feed) { {:names=>[preferred_name, primary_name]} }
      context 'when name type not found' do
        let(:type) { 'FOO' }
        it 'returns false' do
          expect(name).to eq false
        end
      end
      context 'when name found' do
        let(:type) { 'PRF' }
        it 'returns true' do
          expect(name).to eq true
        end
        it 'includes first, last, and full name in result' do
          expect(name).to eq true
          expect(result[:first_name]).to eq 'Ziggy'
          expect(result[:last_name]).to eq 'Stardust'
          expect(result[:person_name]).to eq 'Ziggy  Stardust'
        end
        context 'when primary name present in set' do
          it 'includes given name and family name in results' do
            expect(name).to eq true
            expect(result[:given_name]).to eq 'Oski'
            expect(result[:family_name]).to eq 'Bear'
          end
        end
        context 'when primary name not present in set' do
          let(:person_feed) { {:names=>[preferred_name]} }
          it 'does not include given name and family name in results' do
            expect(name).to eq true
            expect(result[:given_name]).to eq nil
            expect(result[:family_name]).to eq nil
            expect(result.has_key?(:given_name)).to eq false
            expect(result.has_key?(:family_name)).to eq false
          end
        end
      end
    end
  end

  describe '#has_role' do
    subject { HubEdos::UserAttributes.new(user_id: user_id) }
    it 'finds matching roles' do
      expect(subject.has_role?(:student, :applicant)).to be_truthy
      expect(subject.has_role?(:student)).to be_falsey
      expect(subject.has_role?(:applicant)).to be_truthy
    end
  end
end
