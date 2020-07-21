describe HubEdos::StudentApi::V2::StudentRecord::SchoolType do
  let(:attributes) do
    {
      'code' => 'HS',
      'description' => 'High School',
      'category' => 'Four Year',
    }
  end
  subject { described_class.new(attributes) }
  its(:code) { should eq 'HS' }
  its(:description) { should eq 'High School' }
  its(:category) { should eq 'Four Year' }
end
