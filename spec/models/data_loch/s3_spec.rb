describe DataLoch::S3 do
  subject {described_class.new('s3_test')}

  let(:local_path) { '/tmp/data_loch/analytics_a_la_carte.gz' }
  before do
    FileUtils.mkdir_p('/tmp/data_loch')
    FileUtils.touch local_path
  end

  context 'mock S3' do
    before do
      Aws.config[:s3] = {
        stub_responses: {
          put_object: put_object_response
        }
      }
    end

    after do
      Aws.config[:s3] = nil
    end

    context 'successful upload' do
      let(:put_object_response) do
        {
          etag: "\"123deadbeef123deadbeef\"",
          server_side_encryption: 'AES256',
          version_id: 'SomethingSomethingSomething'
        }
      end
      it 'returns an object key based on parameters' do
        key = subject.upload("daily/8e8847c1bdf012037ee13bb62da8a5c1-2013-10-10/analytics", local_path)
        expect(key).to eq 'exports/go/here/daily/8e8847c1bdf012037ee13bb62da8a5c1-2013-10-10/analytics/analytics_a_la_carte.gz'
      end
    end

    context 'error on upload' do
      let(:put_object_response) { 'AccessDenied' }
      it 'logs errors and returns false' do
        expect(Rails.logger).to receive(:error).with /Error on S3 upload/
        result = subject.upload('analytics', local_path)
        expect(result).to be_nil
      end
    end
  end
end
