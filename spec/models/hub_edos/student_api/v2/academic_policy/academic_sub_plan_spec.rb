describe HubEdos::StudentApi::V2::AcademicPolicy::AcademicSubPlan do
  let(:attributes) do
    {
      'subPlan' => {
        'code' => '250AMSA01U',
        'description' => 'Ecology and the Environment'
      },
      'cipCode' => '11.0199'
    }
  end
  subject { described_class.new(attributes) }
  its(:sub_plan) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:cip_code) { should eq '11.0199' }
  its(:hegis_code) { should eq nil }
  its(:academic_plan) { should eq nil }
end
