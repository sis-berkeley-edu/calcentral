describe User::Academics::Roles do
  subject { described_class.new(user) }
  let(:uid) { '61889' }
  let(:user) { User::Current.new(uid) }
  let(:roles_template) do
    {
      'doctorScienceLaw' => false,
      'grad' => false,
      'haasBusinessAdminMasters' => false,
      'haasBusinessAdminPhD' => false,
      'haasEveningWeekendMba' => false,
      'haasExecMba' => false,
      'haasMastersFinEng' => false,
      'haasMbaJurisDoctor' => false,
      'haasMbaPublicHealth' => false,
      'haasFullTimeMba' => false,
      'jurisSocialPolicyMasters' => false,
      'jurisSocialPolicyPhC' => false,
      'jurisSocialPolicyPhD' => false,
      'lawJdCdp' => false,
      'masterOfLawsLlm' => false,
    }
  end
  let(:current_roles) { roles_template.dup }
  let(:historical_roles) { roles_template.dup }
  let(:roles_hash) { {current: current_roles, historical: historical_roles} }
  let(:my_academic_roles) { double(get_feed: roles_hash) }
  before { allow(MyAcademics::MyAcademicRoles).to receive(:new).with(uid).and_return(my_academic_roles) }

  describe '#collect_roles' do
    it 'converts roles hash into array of symbols' do
      roles_hash = {
        'ugrd' => true,
        'grad' => false,
        'law' => false,
        'concurrent' => false,
        'lettersAndScience' => true,
      }
      result = subject.collect_roles(roles_hash)
      expect(result).to eq [:ugrd, :lettersAndScience]
    end
  end

  describe '#current_user_roles' do
    let(:current_roles) { {'grad' => true, 'ugrd' => false} }
    it 'returns current user roles' do
      expect(subject.current_user_roles).to eq [:grad]
    end
  end

  describe '#historic_user_roles' do
    let(:historical_roles) { {'ugrd' => true, 'grad' => true} }
    it 'returns historic user roles' do
      expect(subject.historic_user_roles).to eq [:ugrd, :grad]
    end
  end
end
