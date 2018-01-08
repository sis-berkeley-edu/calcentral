describe CampusSolutions::FinancialAidFundingSourcesController do

  let(:user_id) { '12345' }

  context 'financial data feed' do
    let(:feed) { :get }
    let(:options) { {aid_year: '2016', format: 'json'} }

    context 'unauthenticated user' do
      it 'returns 401' do
        get feed, options
        expect(response.status).to eq 401
      end
    end

    context 'authenticated user' do
      before { session['user_id'] = user_id }
      it 'has some field mapping info' do
        get feed, options
        json = JSON.parse(response.body)
        expect(json['message']).to eq 'YOU CANNOT REDUCE OR CANCEL THIS LOAN.'
      end

      context 'no aid year provided' do
        let(:options) { {format: 'json'} }
        it 'returns empty' do
          get feed, options
          json = JSON.parse response.body
          expect(json).not_to include 'feed'
        end
      end
    end
  end

end
