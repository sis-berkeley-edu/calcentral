describe HubEdos::StudentApi::V2::Student::StudentAttribute do
  let(:attributes) do
    {
      'type' => {
        'code' => '+R99',
        'description' => 'CNP Exception'
      },
      'reason' => {
        'code' => 'SF20%',
        'description' => 'Exception from CNP',
        'formalDescription' => 'You have an exception from Cancellation for Non Payment (CNP) for this term. You will not be dropped from your classes for this term. You remain financially responsible for all charges on your Student Account. Please monitor your communications and tasks in CalCentral for updates.'
      },
      'fromTerm' => {
        'id' => '2172',
        'name' => '2017 Spring',
        'category' => {
          'code' => 'R',
          'description' => 'Regular Term'
        },
        'academicYear' => '2017',
        'beginDate' => '2017-01-10',
        'endDate' => '2017-05-12'
      },
      'toTerm' => {
        'id' => '2172',
        'name' => '2017 Spring',
        'category' => {
          'code' => 'R',
          'description' => 'Regular Term'
        },
        'academicYear' => '2017',
        'beginDate' => '2017-01-10',
        'endDate' => '2017-05-12'
      },
      'fromDate' => '2017-01-11'
    }
  end
  subject { described_class.new(attributes) }
  its(:type) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:type_code) { should eq '+R99' }
  its(:reason) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:from_term) { should be_an_instance_of HubEdos::StudentApi::V2::Term::Term }
  its(:to_term) { should be_an_instance_of HubEdos::StudentApi::V2::Term::Term }
  its(:from_date) { should be_an_instance_of Date }
end
