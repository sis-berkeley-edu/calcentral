describe HubEdos::StudentApi::V2::Student::AcademicStatus do
  let(:attributes) do
    {
      'studentCareer' => {},
      'studentPlans' => [
        {
          'academicPlan' => {},
          'statusInPlan' => {},
          'expectedGraduationTerm' => {},
          'primary' => false,
          'fromDate' => '2020-03-09',
        }
      ],
    }
  end
  subject { described_class.new(attributes) }
  its(:student_career) { should be_an_instance_of HubEdos::StudentApi::V2::Student::StudentCareer }
  its(:student_plans) { should be_an_instance_of HubEdos::StudentApi::V2::Student::StudentPlans }
end
