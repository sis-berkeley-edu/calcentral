describe HubEdos::StudentApi::V2::Student::StudentCareer do
  let(:attributes) do
    {
      'academicCareer' => {
        'code' => 'UGRD',
        'description' => 'Undergrad',
        'formalDescription' => 'Undergraduate',
      },
      'matriculation' => {
        'term' => {
          'id' => '2198',
          'name' => '2019 Fall',
          'category' => {
            'code' => 'R',
            'description' => 'Regular Term'
          },
          'academicYear' => '2020',
          'beginDate' => '2019-08-21',
          'endDate' => '2019-12-20',
        },
        'type' => {
          'code' => 'FYR',
          'description' => 'First Year',
          'formalDescription' => 'First Year Student'
        },
        'homeLocation' => {
          'code' => '038',
          'description' => 'San Francisco County'
        },
      },
      'fromDate' => '2020-03-09',
      'toDate' => '2022-12-14',
    }
  end

  subject { described_class.new(attributes) }
  its(:academic_career) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:matriculation) { should be_an_instance_of HubEdos::StudentApi::V2::StudentRecord::Matriculation }
  its(:from_date) { should be_an_instance_of Date }
  its(:to_date) { should be_an_instance_of Date }
end
