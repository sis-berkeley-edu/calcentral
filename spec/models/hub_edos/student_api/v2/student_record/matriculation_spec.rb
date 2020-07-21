describe HubEdos::StudentApi::V2::StudentRecord::Matriculation do
  let(:attributes) do
    {
      'term' => {
        'id' => '2198',
        'name' => '2019 Fall',
        'category' => {
          'code' => 'R',
          'description' => 'Regular Term'
        },
        'academicYear' => '2020',
        'beginDate' => '2019-08-21',
        'endDate' => '2019-12-20'
      },
      'type' => {
        'code' => 'FYR',
        'description' => 'First Year',
        'formalDescription' => 'First Year Student'
      },
      'homeLocation' => {
        'code' => '016',
        'description' => 'Kings County'
      }
    }
  end
  subject { described_class.new(attributes) }
  its(:term) { should be_an_instance_of HubEdos::StudentApi::V2::Term::Term }
  its(:type) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:home_location) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
end
