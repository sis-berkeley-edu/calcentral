describe HubEdos::Common::Reference::Party do
  let(:attributes) do
    {
      'id' => 'STDNT',
      'name' => 'Student',
    }
  end
  subject { described_class.new(attributes) }

  context 'when no attributes present' do
    let(:attributes) { nil }
    its(:id) { should eq nil }
    its(:name) { should eq nil }
    its(:as_json) { should eq({}) }
  end

  its(:id) { should eq 'STDNT' }
  its(:name) { should eq 'Student' }
  its(:as_json) do
    should eq(
      {
        :id => 'STDNT',
        :name => 'Student',
      }
    )
  end
end
