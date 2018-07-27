describe Cal1card::Photo do
  let(:proxy) { Cal1card::Photo.new(uid, fake: fake) }
  subject { proxy.get_feed }

  shared_examples 'a proxy returning valid photo data' do
    it 'includes bytes and length' do
      expect(subject[:length]).to be_present
      expect(subject[:photo]).to be_present
    end
    it 'calculates length correctly' do
      expect(subject[:length]).to eq subject[:photo].length.to_s
    end
  end

  context 'fake proxy' do
    let(:fake) { true }
    let(:uid) { '61889' }
    it_behaves_like 'a polite HTTP client'
    it_behaves_like 'a proxy returning valid photo data'
    context 'photo not found' do
      let(:status) { 404 }
      before { proxy.set_response(status: status) }
      it 'logs at debug and returns empty feed' do
        allow(Rails.logger).to receive :debug
        expect(Rails.logger).to receive(:debug).with /404 response/
        expect(Rails.logger).not_to receive :error
        expect(subject).to be_empty
      end
    end
    context 'server errors' do
      let(:status) { 506 }
      before { proxy.set_response(status: status) }
      include_context 'expecting logs from server errors'
      it 'reports an error' do
        expect(subject[:body]).to eq('An unknown server error occurred')
        expect(subject[:statusCode]).to eq 503
      end
    end
  end
end
