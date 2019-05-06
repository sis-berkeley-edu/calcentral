describe PingController do

  context 'User database unavailable' do
    before do
      User::Data.stub(:database_alive?).and_return(false)
    end
    it 'raises error' do
      expect(Rails.logger).to receive(:fatal)
      get :do
      expect(response.status).to eq 503
    end
  end

  context 'User database available' do
    let (:expected) { { 'server_alive' => true }.to_json }
    before do
      User::Data.stub(:database_alive?).and_return(true)
    end

    it 'renders a json file with server status' do
      get :do
      expect(response.body).to eq expected
    end
  end
end
