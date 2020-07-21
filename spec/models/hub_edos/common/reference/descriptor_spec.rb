describe HubEdos::Common::Reference::Descriptor do
  let(:attributes) do
    {
      'code' => 'PRF',
      'description' => 'Preferred',
      'formalDescription' => 'Preferred',
    }
  end

  context 'when no attributes present' do
    let(:attributes) { nil }
    its(:code) { should eq nil }
    its(:description) { should eq nil }
    its(:formal_description) { should eq nil }
    its(:as_json) { should eq({}) }
  end

  subject { described_class.new(attributes) }
  its(:code) { should eq('PRF') }
  its(:description) { should eq('Preferred') }
  its(:formal_description) { should eq('Preferred') }
  its(:as_json) do
    should eq(
      {
        :code => 'PRF',
        :description => 'Preferred',
        :formalDescription => 'Preferred'
      }
    )
  end
  context 'when value is nil' do
    before { subject.data['formalDescription'] = nil }
    its(:as_json) do
      should eq(
        {
          :code => 'PRF',
          :description => 'Preferred'
        }
      )
    end
  end
end
