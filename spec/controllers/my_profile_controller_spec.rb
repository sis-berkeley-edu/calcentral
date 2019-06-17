describe MyProfileController do
  before do
    allow(Settings.hub_edos_proxy).to receive(:fake).and_return true
    allow(Settings.campus_solutions_links).to receive(:fake).and_return true
  end
  let(:user_id) { random_id }

  describe '#get_feed' do
    let(:feed) { :get_feed }
    let(:feed_path) { ['feed'] }

    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      it_behaves_like 'a successful feed'
    end
    context 'view-as session' do
      context 'advisor-view-as' do
        let(:view_as_key) { SessionKey.original_advisor_user_id }
        let(:expected_elements) { %w(identifiers names affiliations emails addresses phones emergencyContacts ethnicities usaCountry residency gender links) }
        it_behaves_like 'a successful feed during view-as session'
      end
    end
  end

  describe '#get_edit_link' do
    before do
      allow_any_instance_of(LinkFetcher).to receive(:fetch_link).with('UC_CX_PROFILE', anything).and_return('edit profile link')
      allow_any_instance_of(User::AggregatedAttributes).to receive(:get_feed).and_return({roles: { student: true } })
    end
    let(:feed) { :get_edit_link }
    let(:feed_path) { ['feed','editProfile'] }

    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      it_behaves_like 'a successful feed'
    end
  end
end
