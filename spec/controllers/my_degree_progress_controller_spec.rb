describe MyDegreeProgressController do
  before do
    allow_any_instance_of(User::AggregatedAttributes).to receive(:get_feed).and_return({roles: {graduate: true}})
  end

  context '#get_graduate_milestones' do
    let(:feed) { :get_graduate_milestones }
    it_behaves_like 'an unauthenticated user'
    context 'authenticated user' do
      let(:user_id) { '12345' }
      let(:feed_key) { 'degreeProgress' }

      it_behaves_like 'a successful feed'
    end
  end

  context '#get_undergraduate_requirements' do
    let(:feed) { :get_undergraduate_requirements }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:user_id) { '12345' }
      let(:feed_key) { 'degreeProgress' }

      it_behaves_like 'a successful feed'
    end
  end
end
