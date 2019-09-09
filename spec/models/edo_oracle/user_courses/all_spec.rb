describe EdoOracle::UserCourses::All do
  let(:uid) { random_id }
  let(:student_id) { random_id }
  subject { described_class.new(user_id: uid) }

  let(:enrollment_grades) do
    [
      {
        'student_id' => student_id,
        'institution' => 'UCB01',
        'term_id' => '2198',
        'session_id' => '10W',
        'acad_career' => 'UGRD',
        'crse_career' => 'GRAD',
        'class_section_id' => '10025',
        'units_taken' => BigDecimal.new("4.0"),
        'units_earned' => BigDecimal.new("4.0"),
        'grade' => 'C',
        'grade_points' => BigDecimal.new("8.0"),
        'grading_basis' => 'CNV',
        'include_in_gpa' => 'Y',
        'grading_lapse_deadline_display' => 'N',
        'grading_lapse_deadline' => nil
      }
    ]
  end

  let(:courses) { {} }
  let(:user_courses_base) { double(:user_courses_base, get_all_campus_courses: courses, get_enrollments_summary: courses) }
  before { allow(EdoOracle::UserCourses::Base).to receive(:new).and_return(user_courses_base) }

  describe '#initialize' do
    it 'initializes the uid' do
      expect(subject.instance_eval{ @uid }).to eq uid
    end
  end

  describe '#merge_enrollment_grading' do
    let(:courses) do
      {
        '2019-D' => [
          {
            :course_code => 'HISTORY 7A',
            :term_id => '2198',
            :role => 'Student',
            :sections => [
              {:ccn => '44277', :is_primary_section => true, :units => nil}
            ]
          }
        ]
      }
    end
    let(:grading_table) do
      {
        '2198' => {
          grading_table_class_nbr => {
            'student_id' => student_id,
            'institution' => 'UCB01',
            'term_id' => '2198',
            'session_id' => '10W',
            'acad_career' => 'UGRD',
            'crse_career' => 'GRAD',
            'class_section_id' => grading_table_class_nbr,
            'units_taken' => BigDecimal.new("4.0"),
            'units_earned' => BigDecimal.new("4.0"),
            'grade' => 'C',
            'grade_points' => BigDecimal.new("8.0"),
            'grading_basis' => 'CNV',
            'include_in_gpa' => 'Y',
            'grading_lapse_deadline_display' => 'Y',
            'grading_lapse_deadline' => DateTime.parse('2019-12-28')
          }
        }
      }
    end
    let(:grading_table_class_nbr) { '44277' }
    let(:result) { subject.merge_enrollment_grading(courses) }
    before { allow(subject).to receive(:get_grading_table).and_return(grading_table) }
    context 'when grading present for courses' do
      let(:grading_table_class_nbr) { '44277' }
      it 'returns courses with sections that include units' do
        expect(result.keys.count).to eq 1
        expect(result['2019-D'].count).to eq 1
        expect(result['2019-D'][0][:course_code]).to eq 'HISTORY 7A'
        expect(result['2019-D'][0][:term_id]).to eq '2198'
        expect(result['2019-D'][0][:sections].count).to eq 1
        expect(result['2019-D'][0][:sections][0][:ccn]).to eq '44277'
        expect(result['2019-D'][0][:sections][0][:units]).to eq 4.0
      end
      it 'returns courses with sections that include grading' do
        expect(result['2019-D'][0][:sections][0][:grading][:grade]).to eq 'C'
        expect(result['2019-D'][0][:sections][0][:grading][:gradingBasis]).to eq 'CNV'
        expect(result['2019-D'][0][:sections][0][:grading][:gradePoints]).to eq 8.0
        expect(result['2019-D'][0][:sections][0][:grading][:gradePointsAdjusted]).to eq 8.0
        expect(result['2019-D'][0][:sections][0][:grading][:includeInGpa]).to eq 'Y'
        expect(result['2019-D'][0][:sections][0][:grading][:gradingLapseDeadlineDisplay]).to eq true
        expect(result['2019-D'][0][:sections][0][:grading][:gradingLapseDeadline]).to eq '12/28/19'
      end
    end
    context 'when grading is not present for courses' do
      let(:grading_table_class_nbr) { '12345' }
      it 'returns courses with sections that do not include units' do
        expect(result.keys.count).to eq 1
        expect(result['2019-D'].count).to eq 1
        expect(result['2019-D'][0][:course_code]).to eq 'HISTORY 7A'
        expect(result['2019-D'][0][:term_id]).to eq '2198'
        expect(result['2019-D'][0][:sections].count).to eq 1
        expect(result['2019-D'][0][:sections][0][:ccn]).to eq '44277'
        expect(result['2019-D'][0][:sections][0][:units]).to eq nil
      end
      it 'returns courses with sections that do not include grades' do
        expect(result['2019-D'][0][:sections][0].has_key?(:grading)).to eq false
      end
    end
  end

  describe '#get_grading_table' do
    let(:result) { subject.get_grading_table }
    let(:enrollment_grades) do
      [
        {
          'institution' => 'UCB01',
          'term_id' => '2198',
          'class_section_id' => '10025',
          'grade' => 'C',
        },
        {
          'institution' => 'UCB01',
          'term_id' => '2198',
          'class_section_id' => '10026',
          'grade' => 'A',
        },
        {
          'institution' => 'UCB01',
          'term_id' => '2195',
          'class_section_id' => '10027',
          'grade' => 'B',
        },
      ]
    end
    before { allow(EdoOracle::Queries).to receive(:get_enrollment_grading).and_return(enrollment_grades) }
    it 'returns grading table' do
      expect(result['2198']['10025']['grade']).to eq 'C'
      expect(result['2198']['10026']['grade']).to eq 'A'
      expect(result['2195']['10027']['grade']).to eq 'B'
      expect(result['2198']['10027']).to eq nil
      expect(result['2195']['10025']).to eq nil
      expect(result['2195']['10026']).to eq nil
    end
  end

  describe '#get_section_grading' do
    let(:db_row) do
      {
        'grade' => grade,
        'grade_points' => BigDecimal.new("8.0"),
        'grading_basis' => 'CNV',
        'include_in_gpa' => 'Y',
        'grading_lapse_deadline_display' => 'Y',
        'grading_lapse_deadline' => DateTime.parse('2019-12-20')
      }
    end
    let(:grade) { 'C' }
    let(:is_primary_section) { true }
    let(:section) { {:is_primary_section => is_primary_section} }
    let(:result) { subject.get_section_grading(section, db_row) }
    context 'when section is a primary section' do
      it 'returns grading basis' do
        expect(result[:gradingBasis]).to eq 'CNV'
      end
    end
    context 'when section is not a primary section' do
      let(:is_primary_section) { false }
      it 'excludes grading basis' do
        expect(result[:gradingBasis]).to eq nil
      end
    end
    context 'when grade includes spaces' do
      let(:grade) { '   C ' }
      it 'removes spaces' do
        expect(result[:grade]).to eq 'C'
      end
    end
    it 'includes section grading data' do
      expect(result[:grade]).to eq 'C'
      expect(result[:gradingBasis]).to eq 'CNV'
      expect(result[:gradePoints]).to eq 8.0
      expect(result[:includeInGpa]).to eq 'Y'
    end
    it 'includes adjusted grade points' do
      expect(result[:gradePointsAdjusted]).to eq 8.0
    end
    it 'includes grading lapse deadline data' do
      expect(result[:gradingLapseDeadlineDisplay]).to eq true
      expect(result[:gradingLapseDeadline]).to eq '12/20/19'
    end
  end

  describe '#adjusted_grade_points' do
    let(:grade_points) { BigDecimal.new("4.0") }
    let(:result) { subject.adjusted_grade_points(grade_points, include_in_gpa) }
    context 'when include in gpa is nil' do
      let(:include_in_gpa) { nil }
      it 'returns same grade points value' do
        expect(result).to eq 4.0
      end
    end
    context 'when grade points included in GPA' do
      let(:include_in_gpa) { 'Y' }
      it 'returns grade points value' do
        expect(result).to eq 4.0
      end
    end
    context 'when grade points not included in GPA' do
      let(:include_in_gpa) { 'N' }
      it 'returns 0 value' do
        expect(result).to eq 0.0
      end
    end
  end
end
