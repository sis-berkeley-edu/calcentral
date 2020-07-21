describe HubEdos::PersonApi::V1::Identifier do
  let(:attributes) do
    {
      "type" => "CalNet ID",
      "id" => "oskibear",
      "fromDate" => "2020-04-22",
      "disclose" => false,
    }
  end
  subject { described_class.new(attributes) }
  its(:type) { should eq('CalNet ID') }
  its(:id) { should eq('oskibear') }
  its(:from_date) { should be_an_instance_of(Date) }
  its('from_date.to_s') { should eq('2020-04-22') }
  its(:disclose) { should eq(false) }
  its(:as_json) do
    should eq(
      {
        :type => 'CalNet ID',
        :id => 'oskibear',
        :fromDate => '2020-04-22',
        :disclose => false,
      }
    )
  end
end
