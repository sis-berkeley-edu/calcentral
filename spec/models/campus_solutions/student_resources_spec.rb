describe CampusSolutions::StudentResources do

  let(:uid) { '61889' }
  let(:fake_proxy) { true }
  let(:proxy) { CampusSolutions::StudentResources.new({ user_id: uid, fake: fake_proxy }) }
  before {
    allow_any_instance_of(CampusSolutions::StudentResources).to receive(:lookup_campus_solutions_id).and_return('12345')
  }

  subject { proxy.get }
  it_behaves_like 'a proxy that got data successfully'
  it 'returns data with the expected structure' do
    resources = subject[:feed][:resources]
    expect(resources).not_to be_empty
    expect(resources.count).to eq 12
  end
end
