describe HubEdos::StudentApi::V2::AcademicPolicy::AcademicPlan do
  let(:attributes) do
    {
      'plan' => {
        'code' => '25000U',
        'description' => 'Letters & Sci Undeclared UG',
        'formalDescription' => 'Undeclared College of Letters and Science',
      },
      'type' => {
        'code' => 'MAJ',
        'description' => 'Major - Regular Acad/Prfnl',
        'formalDescription' => 'Major - Regular Acad/Prfnl',
      },
      'cipCode' => '24.0102',
      'targetDegree' => {
        'type' => {
          'code' => 'BACHL',
          'description' => 'Bachelor\'s Degree',
          'formalDescription' => 'Bachelor\'s Degree',
        }
      },
      'ownedBy' => [
        {
          'organization' => {
            'code' => 'CLS',
            'description' => 'Clg of Letters & Science',
            'formalDescription' => 'College of Letters and Science',
          },
          'percentage' => 100.0
        }
      ],
      'academicProgram' => {
        'program' => {
          'code' => 'UCLS',
          'description' => 'UG L&S',
          'formalDescription' => 'Undergrad Letters & Science',
        },
        'academicGroup' => {
          'code' => 'CLS',
          'description' => 'L&S',
          'formalDescription' => 'College of Letters and Science',
        },
        'academicCareer' => {
          'code' => 'UGRD',
          'description' => 'Undergrad',
          'formalDescription' => 'Undergraduate',
        },
      },
    }
  end

  subject { described_class.new(attributes) }

  context 'when no attributes present' do
    let(:attributes) { nil }
    its(:plan) { should eq nil }
    its(:type) { should eq nil }
    its(:cip_code) { should eq nil }
    its(:target_degree) { should eq nil }
    its(:owned_by) { should eq nil }
    describe '#to_json' do
      it 'returns json representation' do
        json_result = subject.to_json
        hash_result = JSON.parse(json_result)
        expect(hash_result).to eq({})
      end
    end
  end

  its(:plan) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:type) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:cip_code) { should eq '24.0102' }
  its(:target_degree) { should be_an_instance_of HubEdos::StudentApi::V2::AcademicPolicy::AcademicDegree }
  its(:owned_by) { should be_an_instance_of HubEdos::StudentApi::V2::AcademicPolicy::AdministrativeOwners }
  its('owned_by.all') { should be_an_instance_of Array }
  its('owned_by.all.first') { should be_an_instance_of HubEdos::StudentApi::V2::AcademicPolicy::AdministrativeOwner }
  its(:academic_program) { should be_an_instance_of HubEdos::StudentApi::V2::AcademicPolicy::AcademicProgram }
end
