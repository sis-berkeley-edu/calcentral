describe CampusSolutions::Sir::Deposit do

  let(:user_id) { '12348' }

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:depositResponse]).to be
      expect(subject[:feed][:depositResponse][:deposit][:emplid]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::Sir::Deposit.new(fake: true, user_id: user_id, adm_appl_nbr: '00000087') }
    it_should_behave_like 'a proxy that gets data'
    subject { proxy.get }
    it 'should get specific mock data' do
      expect(subject[:feed][:depositResponse][:deposit][:emplid]).to eq '24188949'
      expect(subject[:feed][:depositResponse][:deposit][:dueDt]).to eq '2015-09-01'
    end
  end

  # TODO This UID and ADM_APPL_NBR no longer work with our upstream data source. New test data is needed.
  skip 'SISRP-13071' do
    context 'real proxy', testext: true do
      let(:proxy) { CampusSolutions::Sir::Deposit.new(fake: false, user_id: user_id, adm_appl_nbr: '00000087') }
      it_should_behave_like 'a proxy that gets data'
    end
  end

end
