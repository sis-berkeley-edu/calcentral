describe Links::MyCampusLinks do

  describe '#get_feed' do
    before do
      allow(Settings.features).to receive(:campus_links_from_file).and_return(campus_links_from_file)
    end
    context 'when the campus_links_from_file feature flag is on' do
      subject { Links::MyCampusLinks.new }
      let(:campus_links_from_file) { true }

      it 'should retrieve links configuration from the JSON file' do
        expect(subject).to receive(:get_from_file)
        expect(subject).not_to receive(:get_from_database)
        subject.get_feed
      end
      it 'should return the links and navigation' do
        links = subject.get_feed
        expect(links.keys).to contain_exactly('links', 'navigation')
      end
    end
    context 'when the campus_links_from_file feature flag is off' do
      subject { Links::MyCampusLinks.new }
      let(:campus_links_from_file) { false }

      it 'should retrieve links configuration from Postgres' do
        expect(subject).to receive(:get_from_database)
        expect(subject).not_to receive(:get_from_file)
        subject.get_feed
      end
      it 'should return the links and navigation' do
        links = subject.get_feed
        expect(links.keys).to contain_exactly('links', 'navigation')
      end
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
