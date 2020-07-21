describe HubEdos::StudentApi::V2::AcademicPolicy::AcademicProgram do
  let(:attributes) do
    {
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
      'ownedBy' => [{}],
      'academicCareer' => {
        'code' => 'UGRD',
        'description' => 'Undergrad',
        'formalDescription' => 'Undergraduate',
      },
    }
  end
  subject { described_class.new(attributes) }
  its(:program) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:academic_group) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:owned_by) { should be_an_instance_of HubEdos::StudentApi::V2::AcademicPolicy::AdministrativeOwners }
  its('owned_by.all') { should be_an_instance_of Array }
  its(:academic_career) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
end
