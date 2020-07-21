describe HubEdos::StudentApi::V2::AcademicPolicy::AdministrativeOwner do
  let(:attributes) do
    {
      'organization' => {
        'code' => 'CLS',
        'description' => 'Clg of Letters & Science',
        'formalDescription' => 'College of Letters and Science'
      },
      'percentage' => 100.0
    }
  end
  subject { described_class.new(attributes) }
  its(:organization) { should be_an_instance_of HubEdos::Common::Reference::Descriptor }
  its(:percentage) { should eq 100.0 }

  describe '#organization' do
    context 'when organization is not present' do
      let(:attributes) { {'percentage' => 100.0} }
      it 'returns nil' do
        expect(subject.organization).to eq nil
      end
    end
  end
end
