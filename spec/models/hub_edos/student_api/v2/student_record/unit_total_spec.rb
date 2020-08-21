describe HubEdos::StudentApi::V2::StudentRecord::UnitTotal do
  let(:attributes) do
    {
      'type' => {
        'code' => 'Total',
        'description' => 'Total Units',
      },
      'unitsEnrolled' => 4,
      'unitsTaken' => 71,
      'unitsPassed' => 56,
      'unitsTest' => 13.3,
      'unitsCumulative' => 69.3,
    }
  end
  subject { described_class.new(attributes) }
  its(:type) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:units_enrolled) { should eq 4.0 }
  its(:units_taken) { should eq 71.0 }
  its(:units_passed) { should eq 56.0 }
  its(:units_test) { should eq 13.3 }
  its(:units_cumulative) { should eq 69.3 }
end
