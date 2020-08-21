describe HubEdos::StudentApi::V2::AcademicPolicy::AcademicDegree do
  let(:attributes) do
    {
      'type' => {
        'code' => 'BACHL',
        'description' => 'Bachelor\'s Degree',
        'formalDescription' => 'Bachelor\'s Degree',
      },
      'abbreviation' => 'BS'
    }
  end

  subject { described_class.new(attributes) }
  its(:type) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:abbreviation) { should eq 'BS' }
end
