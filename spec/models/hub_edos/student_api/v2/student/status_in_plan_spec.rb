describe HubEdos::StudentApi::V2::Student::StatusInPlan do
  let(:attributes) do
    {
      'status' => {
        'code' => 'AC',
        'description' => 'Active',
        'formalDescription' => 'Active in Program'
      },
      'action' => {
        'code' => 'DATA',
        'description' => 'Data Chg',
        'formalDescription' => 'Data Change'
      },
      'reason' => {
        'code' => 'GTOI',
        'description' => 'Grad Term - Auto Opt-In',
        'formalDescription' => 'Graduation Term - Automatic Opt-In',
      }
    }
  end

  subject { described_class.new(attributes) }
  its(:status) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:status_code) { should eq 'AC' }
  its(:action) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:reason) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
end
