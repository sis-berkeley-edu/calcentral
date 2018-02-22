describe CampusSolutions::FinancialResourcesParameterized do
  let(:uid) { 61889 }
  let(:model) { described_class }
  let(:link_api_response) { { url: true } }

  describe 'attempting to get CS links' do
    before do
      allow_any_instance_of(LinkFetcher).to receive(:fetch_link).and_return link_api_response
    end

    context 'while passing the aid_year parameter' do
      subject { model.new({ aid_year: 2018 }).get_feed_internal }
      it 'returns a valid summer estimator link' do
        expect(subject[:summerEstimator][:url]).to be_truthy
      end
    end

    context 'while not passing the aid_year paramter' do
      subject {model.new().get_feed_internal}
      it 'does not return a summer estimator link' do
        expect(subject.has_key?(:summerEstimator)).to be_falsey
      end
    end

  end

end
