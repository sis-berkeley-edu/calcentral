describe Eft::MyEftEnrollment do
  let (:uid) { '61889' }
  let (:fake_model) { Eft::MyEftEnrollment.new(uid, fake: true) }
  let (:real_model) { Eft::MyEftEnrollment.new(uid, fake: false) }
  let (:eft_uri) { URI.parse(Settings.eft_proxy.base_url) }

  describe 'proper caching behaviors' do
    context 'on success' do
      subject { fake_model }
      it 'should write to cache' do
        subject.get_feed_as_json
      end
    end
  end

  describe '#get_parsed_response' do
    subject { fake_model.get_parsed_response }
    context 'fetching fake data feed' do
      it_behaves_like 'a polite HTTP client'
      it 'has correctly parsed JSON' do
        expect(subject[:statusCode]).to eq 200
        expect(subject["data"]["eftStatus"]).to eq "active"
      end
    end
  end

  describe 'exception handling' do
    subject { real_model }
    context 'fetching a real data feed and stubbing a 404' do
      before do
        stub_request(:any, /.*#{eft_uri.hostname}.*/).to_return(status: 404)
      end
      it 'should return a 404 with an error message' do
        feed = subject.get_parsed_response
        expect(feed[:statusCode]).to eq 404
        expect(feed[:errorMessage]).to eq "No EFT data could be found for your account"
      end
    end
  end

end
