describe User::SearchUsersByName do
  let(:name) { nil }
  let(:roles) { [] }
  let(:opts) do
    {
      include_guest_users: true,
      roles: roles,
    }
  end
  let(:proxy) { User::SearchUsersByName.new }
  subject { proxy.search_by name, opts }

  shared_examples "a search with empty input" do
    context "nil input" do
      it { should be_empty }
    end
    context "blank input" do
      let(:name) { "    " }
      it { should be_empty }
    end
  end

  context "SISEDO search" do
    let(:search_results) do
      [
        {
          'student_id' => '12345',
          'campus_id' => '54321',
          'first_name_legal' => 'Dwight',
          'middle_name_legal' => ' ',
          'last_name_legal' => 'Schrute',
          'first_name_preferred' => nil,
          'middle_name_preferred' => nil,
          'email' => "dschrute@example.com",
          'academic_programs' => "GACAD"
        }
      ]
    end
    it_should_behave_like "a search with empty input"
    context 'filter by role' do
      let(:name) { random_name }
      let(:roles) { [:student, :exStudent] }
      let(:uid) { random_id }
      before do
        # Search should only use SISEDO to get UIDs, and then rely on merged attributes to check roles.
        sisedo_records = [:faculty, :student, :staff, :exStudent].each_with_index.map do |role, i|
          uid = (i + 1).to_s
          allow(User::AggregatedAttributes).to receive(:new).with(uid).and_return double(get_feed: {ldapUid: uid, roles: { role => true }})
          {'campus_uid' => uid}
        end
        allow(EdoOracle::Queries).to receive(:search_students).and_return sisedo_records
      end
      it 'should only match on student-related roles' do
        expect(subject).to have(2).items
        expect(subject[0][:campusUid]).to eq '2'
        expect(subject[1][:campusUid]).to eq '4'
      end
    end
  end
end
