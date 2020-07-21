describe User::Academics::DiplomaSso do

  let(:uid) { '61889' }
  let(:campus_solutions_id) { '1234567' }
  let(:current_user_is_student) { true }
  let(:current_user) { double(User::Current, :uid => uid, :campus_solutions_id => campus_solutions_id, :is_student? => current_user_is_student) }
  let(:cs_cediploma_sso_feed) do
    {
      feed: {
        root: {
          ucSrCediploma: {
            ucSrCediplomaUrl: 'https://www.example.com/sso/1a2b3c4d5e6f7'
          }
        }
      }
    }
  end
  let(:cs_cediploma_sso) { double(get: cs_cediploma_sso_feed) }
  before do
    allow(User::Current).to receive(:new).with(61889).and_return(current_user)
    allow(CampusSolutions::CeDiplomaSso).to receive(:new).with(user_id: uid).and_return(cs_cediploma_sso)
  end

  subject { described_class.new(current_user) }

  describe '#sso_url' do
    it 'returns url string' do
      result = subject.sso_url
      expect(result).to be_an_instance_of String
    end
  end
end
