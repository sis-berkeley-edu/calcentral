describe HubEdos::StudentApi::V2::AcademicPolicy::AcademicSubPlans do
  let(:academic_sub_plans) do
    [
      {
        'subPlan' => {
          'code' => '250AMSA01U',
          'description' => 'Ecology and the Environment'
        },
        'cipCode' => '11.0199'
      }
    ]
  end
  subject { described_class.new(academic_sub_plans) }
  its(:all) { should be_an_instance_of Array }
  its('all.first') { should be_an_instance_of HubEdos::StudentApi::V2::AcademicPolicy::AcademicSubPlan }
end
