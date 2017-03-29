# Proxy Shared Examples
# Used to provide test functionality that is shared across proxy tests.

shared_context 'expecting logs from server errors' do
  before(:each) do
    expect(Rails.logger).to receive(:error) do |error_message|
      lines = error_message.lines.to_a
      expect(lines[0]).to match(/url: http/)
      expect(lines[0]).to match(/status: #{status}/)
      expect(lines[1]).to match(/Associated key:/)
      expect(lines[1]).to match(/uid: #{uid}/) if defined? uid
      expect(lines[1]).to match(/Response body: #{body}/) if defined? body
    end
  end
end

shared_examples 'a proxy logging errors' do
  let! (:body) { 'An unknown error occurred.' }
  let! (:status) { 506 }
  include_context 'expecting logs from server errors'
  before(:each) { stub_request(:any, /.*/).to_return(status: status, body: body) }

  it 'logs errors' do
    subject
  end
end

shared_examples 'a polite HTTP client' do
  after { WebMock.reset! }
  it 'includes default request headers' do
    subject
    expect(a_request(:any, /.*/).with(headers: {'Accept' => '*/*', 'User-Agent' => 'Ruby'})).to have_been_made.at_least_once
  end
end
