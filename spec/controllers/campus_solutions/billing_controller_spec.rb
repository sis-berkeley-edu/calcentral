describe CampusSolutions::BillingController do

  let(:user_id) { '12345' }

  context 'billing feed' do
    let(:feed) { :get_activity }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:feed_key) { 'summary' }
      it_behaves_like 'a successful feed'
      it 'has some field mapping info' do
        session['user_id'] = user_id
        get feed
        json = JSON.parse(response.body)
        expect(json['feed']['activity'][0]['itemDescription']).to eq 'Class Pass Fee - Transit'
      end
    end
  end

end
