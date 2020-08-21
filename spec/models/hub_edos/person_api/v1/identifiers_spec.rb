describe HubEdos::PersonApi::V1::Identifiers do
  let(:identifiers_data) do
    [
      {
        "type" => "student-id",
        "id" => "11667051",
        "disclose" => false,
      },
      {
        "type" => "campus-uid",
        "id" => "61889",
        "disclose" => false
      },
      {
        "type" => "CalNet ID",
        "id" => "oskibear",
        "fromDate" => "2020-04-22",
        "disclose" => false,
      }
    ]
  end
  subject { described_class.new(identifiers_data) }

  describe '#all' do
    its('all.count') { should eq(3) }
    it 'should return only idenfifier objects' do
      subject.all.each do |identifier|
        expect(identifier).to be_an_instance_of HubEdos::PersonApi::V1::Identifier
      end
    end
  end

end
