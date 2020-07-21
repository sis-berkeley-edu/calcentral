describe HubEdos::StudentApi::V2::Student::StudentPlans do
  let(:attributes) { [{}] }
  subject { described_class.new(attributes) }
  its(:all) { should be_an_instance_of Array }
  its('all.first') { should be_an_instance_of HubEdos::StudentApi::V2::Student::StudentPlan }
end
