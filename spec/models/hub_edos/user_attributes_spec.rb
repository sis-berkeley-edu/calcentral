# encoding: UTF-8
describe HubEdos::UserAttributes do

  let(:user_id) { '61889' }
  let(:confidential_student) { false }
  let(:fake_contact_proxy) { HubEdos::Contacts.new(fake: true, user_id: user_id) }
  before { allow(HubEdos::Contacts).to receive(:new).and_return fake_contact_proxy }

  let(:fake_crosswalk_proxy) { CalnetCrosswalk::ByUid.new(fake:true, user_id: user_id) }
  before { allow(CalnetCrosswalk::ByUid).to receive(:new).and_return fake_crosswalk_proxy }

  subject { HubEdos::UserAttributes.new(user_id: user_id).get }

  it 'should provide the converted person data structure' do
    expect(subject[:ldap_uid]).to eq '61889'
    expect(subject[:campus_solutions_id]).to eq '11667051'
    expect(subject[:student_id]).to eq '11667051'
    expect(subject[:given_name]).to eq 'Oski'
    expect(subject[:family_name]).to eq 'Bear'
    expect(subject[:first_name]).to eq 'Ziggy'
    expect(subject[:last_name]).to eq 'Stardust'
    expect(subject[:person_name]).to eq 'Ziggy  Stardust '
    expect(subject[:email_address]).to eq 'oski@gmail.com'
    expect(subject[:official_bmail_address]).to eq 'oski@berkeley.edu'
    expect(subject[:names]).to be
    expect(subject[:addresses]).to be
    expect(subject[:roles]).to eq({applicant: true})
  end

  describe 'student_id depends on role' do
    before do
      allow_any_instance_of(HubEdos::Contacts).to receive(:get).and_return(
        {feed: {'student' => {
          'identifiers' => [{'id' => '11667051', 'type' => 'student-id'}],
          'affiliations' => affiliations,
          'confidential' => confidential_student
        }}}
      )
    end
    context 'non-student with Campus Solutions ID' do
      let(:affiliations) do
        [
          {type: {code: 'EMPLOYEE'}, status: {code: 'ACT'}}
        ]
      end
      it 'does not set student_id' do
        expect(subject[:student_id]).to be_nil
      end
    end
    context 'student' do
      let(:affiliations) do
        [
          {type: {code: 'STUDENT'}, status: {code: 'ACT'}},
          {type: {code: 'UNDERGRAD'}, status: {code: 'ACT'}}
        ]
      end
      it 'does set student_id' do
        expect(subject[:student_id]).to eq subject[:campus_solutions_id]
      end
      it 'does not set a confidential role value if the flag is false' do
        expect(subject[:roles].keys).not_to include(:confidential)
      end
      context 'with confidential flag' do
        let(:confidential_student) { true }
        it 'includes a confidential role' do
          expect(subject[:roles][:confidential]).to eq true
        end
      end
    end
  end

  context 'Contacts feed contains all necessary data' do
    it 'does not bother calling the Affiliations API' do
      expect(HubEdos::Affiliations).to receive(:new).never
      expect(subject[:roles]).to eq({applicant: true})
    end
  end
  context 'Contacts feed is unexpectedly reticent' do
    let(:fake_affiliations_proxy) { HubEdos::Affiliations.new(fake: true, user_id: user_id) }
    before do
      allow_any_instance_of(HubEdos::Contacts).to receive(:get).and_return(
        {feed: {'student' => {}}}
      )
    end
    it 'reluctantly falls back on the Affiliations API' do
      expect(HubEdos::Affiliations).to receive(:new).and_return fake_affiliations_proxy
      expect(subject[:roles]).to eq({applicant: true})
    end
  end

  context 'unexpected errors from Hub calls' do
    before do
      allow_any_instance_of(HubEdos::Contacts).to receive(:get_internal).and_return({'non' => 'sense'})
    end
    it 'returns from errors' do
      expect(subject).to eq({
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
    expect(subject[:roles]).to eq({chancellor: true, graduate: true})
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
