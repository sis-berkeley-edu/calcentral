describe HubEdos::StudentApi::V2::AcademicPolicy::AdministrativeOwners do
  let(:administrative_owners) do
    [
      {
        'organization' => {
          'code' => 'CLS',
          'description' => 'Clg of Letters & Science',
          'formalDescription' => 'College of Letters and Science'
        },
        'percentage' => 100.0
      }
    ]
  end
  subject { described_class.new(administrative_owners) }
  its(:all) { should be_an_instance_of Array }
end
