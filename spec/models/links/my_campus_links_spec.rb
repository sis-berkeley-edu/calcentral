describe Links::MyCampusLinks do

  describe '#load_cs_link_api_entries' do
    let(:link_json) do
      {
        'links' => [
          {
            'name' => 'Static Link 1 Name',
            'hoverText' => 'Static Link 1 Description',
            'url' => 'http://www.example.com/static_link_1/',
          },
          {
            'cs_link_id' => 'UC_CX_ACCOMM_HUB_STUDENT'
          },
          {
            'name' => 'Static Link 2 Name',
            'hoverText' => 'Static Link 2 Description',
            'url' => 'http://www.example.com/static_link_2/',
          },
        ],
        'navigation' => []
      }
    end
    let(:cs_link_hash) do
      {
        urlId: 'UC_CX_ACCOMM_HUB_STUDENT',
        url: 'https://bcs.example.com:1234/accommodation_hub_student',
        ucFrom: 'CalCentral',
        ucFromText: 'CalCentral',
        ucFromLink: 'https://calcentral-sis01.example.com/',
        name: 'Academic Accommodations Hub',
        title: 'Academic Accommodations Hub for Students',
        isCsLink: true
      }
    end
    before do
      allow(LinkFetcher).to receive(:fetch_link).with('UC_CX_ACCOMM_HUB_STUDENT').and_return(cs_link_hash)
    end
    it 'should merge cs link api properties with link when cs_link_id present' do
      links = subject.load_cs_link_api_entries(link_json)
      links_array = links['links']
      expect(links_array[0]['name']).to eq 'Static Link 1 Name'
      expect(links_array[1]['name']).to eq 'Academic Accommodations Hub'
      expect(links_array[1]['hoverText']).to eq 'Academic Accommodations Hub for Students'
      expect(links_array[1]['url']).to eq 'https://bcs.example.com:1234/accommodation_hub_student'
      expect(links_array[1][:ucFrom]).to eq 'CalCentral'
      expect(links_array[1][:ucFromText]).to eq 'CalCentral'
      expect(links_array[1][:ucFromLink]).to eq 'https://calcentral-sis01.example.com/'
      expect(links_array[2]['name']).to eq 'Static Link 2 Name'
    end
  end

  describe '#campus_links_json' do
    it 'should return the links and navigation' do
      links = subject.campus_links_json
      expect(links.keys).to contain_exactly('links', 'navigation')
    end
  end

  describe '#get_roles_for_link' do
    context 'user roles that can see a particular link' do
      let(:roles_for_link) {
        roles_for_link = []
        roles.each { |role| roles_for_link << double(slug: role) }
        Links::MyCampusLinks.new.get_roles_for_link double user_roles: roles_for_link
      }
      context 'ex-students' do
        subject { roles_for_link['exStudent'] }
        context 'student gets a link' do
          let(:roles) { %w(student exStudent) }
          it { should be true }
        end
        context 'no link for student role' do
          let(:roles) { %w(applicant staff faculty student) }
          it { should be false }
        end
      end
    end
  end
end
