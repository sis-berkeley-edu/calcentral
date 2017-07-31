describe CampusSolutions::AdvisingResourcesController do
  let(:user_id) { '12349' }
  let(:feed) { :get }
  it_behaves_like 'an unauthenticated user'

  context 'authenticated user' do
    before do
      session['user_id'] = user_id
      allow(HubEdos::UserAttributes).to receive(:new).with(user_id: user_id).and_return double(get: {campus_solutions_id: random_cs_id, roles: user_roles})
    end

    context 'no advisor privileges' do
      let(:user_roles) { { staff: true, student: true } }
      it 'returns forbidden' do
        get feed
        expect(response.status).to eq 403
      end
    end

    context 'advisor privileges' do
      let(:user_roles) { { staff: true, advisor: true } }
      let(:feed_key) { 'ucAdvisingResources' }

      shared_examples 'a feed with advising resources' do
        it 'contains data' do
          get feed
          json = JSON.parse response.body
          expect(json['feed']).to_not be_nil
        end
      end

      context 'links from CS link API' do
        let(:key) { 'ucClassSearch' }
        let(:expected_name) { 'Class Search' }

        it_behaves_like 'a feed with advising resources'

        it 'returns feed with CS links' do
          get feed
          json = JSON.parse response.body
          cs_links = json['feed']

          expect(link = cs_links[key]).to_not be_nil
          expect(link['isCsLink']).to be true
          expect(link['name']).to eq expected_name
        end
      end

    end
  end

end
