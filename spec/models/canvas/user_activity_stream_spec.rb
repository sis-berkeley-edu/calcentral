describe Canvas::UserActivityStream do

  let(:uid) { Settings.canvas_proxy.test_user_id }
  subject { Canvas::UserActivityStream.new(user_id: uid) }
  let(:response) { subject.user_activity }
  after { WebMock.reset! }

  subject { Canvas::UserActivityStream.new(user_id: uid) }

  context 'on request failure' do
    let(:failing_request) { {method: :get} }
    it_should_behave_like 'an unpaged Canvas proxy handling request failure'
  end
end
