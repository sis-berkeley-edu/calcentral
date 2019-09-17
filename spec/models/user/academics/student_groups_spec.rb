describe User::Academics::StudentGroups do
  let(:uid) { random_id }
  let(:student_groups_feed) do
    [
      {'student_group_code' => 'VELW', 'student_group_description' => 'Entry Level Writing', 'from_date' => DateTime.parse('2001-01-01 00:00:00 UTC')},
      {'student_group_code' => 'AHC', 'student_group_description' => 'American History - Completed', 'from_date' => DateTime.parse('2017-04-18 00:00:00 UTC')},
      {'student_group_code' => 'AIC', 'student_group_description' => 'Amer Institutions - Completed', 'from_date' => DateTime.parse('2017-04-18 00:00:00 UTC')},
      {'student_group_code' => 'VAC', 'student_group_description' => 'American Cultures', 'from_date' => DateTime.parse('2001-01-01 00:00:00 UTC')},
      {'student_group_code' => 'RPRI', 'student_group_description' => 'Priority Enrollment', 'from_date' => DateTime.parse('2019-03-25 00:00:00 UTC')},
    ]
  end
  let(:student_groups_cached) do
    instance_double("User::Academics::StudentGroupsCached").tap do |mock|
      allow(mock).to receive(:get_feed).and_return(student_groups_feed)
    end
  end
  before { allow(User::Academics::StudentGroupsCached).to receive(:new).with(uid).and_return(student_groups_cached) }
  subject { described_class.new(uid) }

  describe '#codes' do
    it 'returns array of student group codes' do
      expect(subject.codes.sort).to eq ['AHC', 'AIC', 'RPRI', 'VAC', 'VELW']
    end
  end
end
