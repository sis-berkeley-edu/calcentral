describe CampusSolutions::StudentResources do

  shared_examples 'a proxy that gets data' do

    before {
      allow_any_instance_of(CampusSolutions::StudentResources).to receive(:lookup_campus_solutions_id).and_return('12345')
    }

    let(:uid) { '61889' }
    let(:proxy) { CampusSolutions::StudentResources.new({ user_id: uid, fake: fake_proxy }) }

    subject { proxy.get }
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      resources = subject[:feed][:resources]
      expect(resources).not_to be_empty
      expect(resources.count).to eq 11
    end
  end

  context 'mock proxy' do
    let(:fake_proxy) { true }
    it_should_behave_like 'a proxy that gets data'
  end

  context 'real proxy', testext: true do
    let(:fake_proxy) { false }
    it_should_behave_like 'a proxy that gets data'
  end

end
