describe CampusSolutions::SirResponseController do

  let(:user_id) { '12350' }
  let(:sir_statuses_feed) {
    {
      sirStatuses: [
        {
          itemStatusCode: 'I',
          chklstItemCd: 'AUSIRF',
          checkListMgmtAdmp: {
            admApplNbr: '00123456'
          }
        }
      ]
    }
  }
  let(:post_response) {
    {
      feed: {
        status: 200
      }
    }
  }

  context 'updating sir response' do
    it 'should not let an unauthenticated user post' do
      post :post, params: { format: 'json', uid: '100' }
      expect(response.status).to eq 401
    end

    context 'authenticated user' do
      before do
        session['user_id'] = user_id
        User::Auth.stub(:where).and_return([User::Auth.new(uid: user_id, is_superuser: false, active: true)])
        CampusSolutions::Sir::SirStatuses.stub_chain(:new, :get_feed).and_return sir_statuses_feed
        CampusSolutions::Proxy.stub(:get).and_return post_response
      end
      it 'should let an authenticated user post' do
        post :post, params: {
          'chklstItemCd' => 'AUSIRF',
          'admApplNbr' => '00123456'
        }
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['statusCode']).to eq 200
        expect(json['feed']).to be
        expect(json['feed']['status']).to be
      end
      it 'should reject a post that fails validation' do
        post :post, params: {
          'studentCarNbr' => '1234',
          'admApplNbr' => '12345678',
          'chklstItemCd' => 'let-me-in-please'
        }
        expect(response.status).to eq 400
        json = JSON.parse(response.body)
        expect(json['feed']).not_to be
        expect(json['error']).to be
      end
    end
  end
end
