describe MyAcademics::Semesters do

  let(:feed) { {}.tap { |feed| MyAcademics::Semesters.new(random_id).merge(feed) } }

  let(:term_keys) { ['2015-D', '2016-B', '2016-C', '2016-D'] }

  def generate_enrollment_data(opts={})
    Hash[term_keys.map{|key| [key, enrollment_term(key, opts)]}]
  end

  def enrollment_term(key, opts={})
    rand(2..4).times.map { course_enrollment(key, opts) }
  end

  def course_enrollment(term_key, opts={})
    term_yr, term_cd = term_key.split('-')
    dept = random_string(5)
    catid = rand(999).to_s
    enrollment = {
      id: "#{dept}-#{catid}-#{term_key}",
      slug: "#{dept}-#{catid}",
      course_code: "#{dept.upcase} #{catid}",
      term_yr: term_yr,
      term_cd: term_cd,
      session_code: [nil, 'A', 'B', 'C', 'D', 'E'].sample,
      dept: dept.upcase,
      catid: catid,
      course_catalog: catid,
      emitter: 'Campus',
      name: random_string(15).capitalize,
      sections: course_enrollment_sections(opts),
      role: 'Student'
    }
    enrollment
  end

  def course_enrollment_sections(opts)
    sections = [ course_enrollment_section(opts.merge(is_primary_section: true)) ]
    rand(1..3).times { sections << course_enrollment_section(opts.merge(is_primary_section: false)) }
    sections
  end

  def course_enrollment_section(opts={})
    format = opts[:format] || ['LEC', 'DIS', 'SEM'].sample
    section_number = opts[:section_number] || "00#{rand(9)}"
    is_primary_section = opts[:is_primary_section] || false
    waitlisted = opts[:waitlisted]
    section = {
      associated_primary_id: opts[:associated_primary_id],
      ccn: opts[:ccn] || random_ccn,
      instruction_format: format,
      is_primary_section: is_primary_section,
      section_label: "#{format} #{section_number}",
      section_number: section_number,
      units: (is_primary_section ? rand(1.0..5.0).round(1) : 0.0),
      grading: {
        grade: is_primary_section ? random_grade : nil,
        grading_basis: 'GRD',
        grade_points: rand(0.0..16.0)
      },
      schedules: {
        oneTime: [],
        recurring: [{
          buildingName: random_string(10),
          roomNumber: rand(9).to_s,
          schedule: 'MWF 11:00A-12:00P'
        }]
      },
      waitlisted: waitlisted,
      instructors: [{name: random_name, uid: random_id}]
    }
    section
  end

  shared_examples 'semester ordering' do
    it 'should include the expected semesters in reverse order' do
      expect(feed[:semesters].length).to eq 4
      term_keys.sort.reverse.each_with_index do |key, index|
        term_year, term_code = key.split('-')
        expect(feed[:semesters][index]).to include({
          termCode: term_code,
          termYear: term_year,
          name: Berkeley::TermCodes.to_english(term_year, term_code)
        })
      end
    end

    it 'should place semesters in the right buckets' do
      current_term = Berkeley::Terms.fetch.current
      current_term_key = "#{current_term.year}-#{current_term.code}"
      feed[:semesters].each do |s|
        semester_key = "#{s[:termYear]}-#{s[:termCode]}"
        if semester_key < current_term_key
          expect(s[:timeBucket]).to eq 'past'
        elsif semester_key > current_term_key
          expect(s[:timeBucket]).to eq 'future'
        else
          expect(s[:timeBucket]).to eq 'current'
        end
      end
    end
  end

  shared_examples 'a good and proper munge' do
    include_examples 'semester ordering'
    it 'should preserve structure of enrollment data' do
      feed[:semesters].each do |s|
        expect(s[:hasEnrollmentData]).to eq true
        enrollment_semester = enrollment_data["#{s[:termYear]}-#{s[:termCode]}"]
        expect(s[:classes].length).to eq enrollment_semester.length
        s[:classes].each do |course|
          matching_enrollment = enrollment_semester.find { |e| e[:id] == course[:course_id] }
          expect(course[:sections].count).to eq matching_enrollment[:sections].count
          expect(course[:title]).to eq matching_enrollment[:name]
          expect(course[:courseCatalog]).to eq matching_enrollment[:course_catalog]
          expect(course[:url]).to include matching_enrollment[:slug]
          [:course_code, :dept, :dept_desc, :role, :slug, :session_code].each do |key|
            expect(course[key]).to eq matching_enrollment[key]
          end
        end
      end
    end

    it 'should not flag it as filtered for delegate' do
      feed[:semesters].each do |s|
        expect(s[:filteredForDelegate]).to eq false
      end
    end
  end

  context 'Campus Solutions academic data' do
    before do
      allow(Settings.terms).to receive(:fake_now).and_return '2016-04-01'
      allow(Settings.terms).to receive(:legacy_cutoff).and_return 'fall-2009'
      expect(CampusOracle::Queries).not_to receive :get_enrolled_sections
      allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
    end
    let(:enrollment_data) { generate_enrollment_data }
    it_should_behave_like 'a good and proper munge'
    it 'advertises Campus Solutions source' do
      expect(feed[:semesters]).to all include({campusSolutionsTerm: true})
    end
  end

  context 'Has withdrawal data' do
    before do
      allow(Settings.terms).to receive(:fake_now).and_return '2016-04-01'
      allow(Settings.terms).to receive(:legacy_cutoff).and_return 'fall-2009'
      expect(CampusOracle::Queries).not_to receive :get_enrolled_sections
      allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
      allow(EdoOracle::Queries).to receive(:get_withdrawal_status).and_return withdrawal_data
    end
    let(:withdrawal_data) do
      [
        {
          'student_id'=>'25259127',
          'acadcareer_code'=>'UGRD',
          'term_id'=>'2158',
          'withcncl_type_code'=>'WDR',
          'withcncl_type_descr'=>'Withdrew',
          'withcncl_reason_code'=>'RETR',
          'withcncl_reason_descr'=>'Retroactive',
          'withcncl_fromdate'=> Time.parse('2016-02-04 00:00:00 UTC'),
          'withcncl_lastattendate'=> Time.parse('2014-12-12 00:00:00 UTC')
        }
      ]
    end
    let(:enrollment_data) { generate_enrollment_data }
    it 'should add withdrawal data' do
      expect([feed[:semesters][3]]).to all include({hasWithdrawalData: true})
    end
  end

  shared_examples 'a good and proper multiple-primary munge' do
    let(:term_keys) { ['2013-D'] }
    let(:enrollment_data) { {'2013-D' => multiple_primary_enrollment_term} }

    let(:classes) { feed[:semesters].first[:classes] }
    let(:multiple_primary_class) { classes.first }
    let(:single_primary_classes) { classes[1..-1] }

    it 'should flag multiple primaries' do
      expect(multiple_primary_class[:multiplePrimaries]).to eq true
      single_primary_classes.each { |c| expect(c).not_to include(:multiplePrimaries) }
    end

    it 'should include slugs and URLs only for primary sections of multiple-primary courses' do
      multiple_primary_class[:sections].each do |s|
        if s[:is_primary_section]
          expect(s[:slug]).to eq "#{s[:instruction_format].downcase}-#{s[:section_number]}"
          expect(s[:url]).to eq "#{multiple_primary_class[:url]}/#{s[:slug]}"
        else
          expect(s).not_to include(:slug)
          expect(s).not_to include(:url)
        end
      end
      single_primary_classes.each do |c|
        c[:sections].each do |s|
          expect(s).not_to include(:slug)
          expect(s).not_to include(:url)
        end
      end
    end

    it 'should associate secondary sections with the correct primaries' do
      expect(multiple_primary_class[:sections][0]).not_to include(:associatedWithPrimary)
      expect(multiple_primary_class[:sections][1]).not_to include(:associatedWithPrimary)
      expect(multiple_primary_class[:sections][2][:associatedWithPrimary]).to eq multiple_primary_class[:sections][0][:slug]
      expect(multiple_primary_class[:sections][3][:associatedWithPrimary]).to eq multiple_primary_class[:sections][1][:slug]
    end
  end

  context 'Campus Solutions multiple-primary munge' do
    before do
      allow(Settings.terms).to receive(:legacy_cutoff).and_return 'summer-2009'
      allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
    end
    let(:multiple_primary_enrollment_term) do
      enrollment_term('2013-D').tap do |term|
        term.first[:sections] = [
          course_enrollment_section(ccn: '10001', is_primary_section: true, format: 'LEC', section_number: '001'),
          course_enrollment_section(ccn: '10002', is_primary_section: true, format: 'LEC', section_number: '002'),
          course_enrollment_section(ccn: '10003', is_primary_section: false, format: 'DIS', section_number: '101', associated_primary_id: '10001'),
          course_enrollment_section(ccn: '10004', is_primary_section: false, format: 'DIS', section_number: '201', associated_primary_id: '10002')
        ]
        term
      end
    end
    it_should_behave_like 'a good and proper multiple-primary munge'
  end

  context 'when a semester has all waitlisted courses, or no enrolled courses' do
    before do
      allow(Settings.terms).to receive(:legacy_cutoff).and_return 'summer-2014'
      allow_any_instance_of(CampusOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
    end
    let(:term_keys) { ['2013-D'] }
    let(:enrollment_data) { {'2013-D' => waitlisted_term} }

    context 'all waitlisted courses' do
      let(:waitlisted_term) do
        enrollment_term('2013-D').tap do |term|
          term.each do |course|
            course[:sections] = [
              course_enrollment_section(is_primary_section: true, waitlisted: true),
              course_enrollment_section(is_primary_section: false, waitlisted: true),
            ]
          end
        end
      end
      it 'should say that there are no enrolled courses' do
        feed[:semesters].each do |semester|
          expect(semester[:hasEnrolledClasses]).to be false
        end
      end
    end

    context 'some waitlisted courses' do
      let(:waitlisted_term) do
        enrollment_term('2013-D').tap do |term|
          term.first[:sections] = [
            course_enrollment_section(waitlisted: true),
            course_enrollment_section(waitlisted: true)
          ]
        end
      end
      it 'should say that there are enrolled courses' do
        feed[:semesters].each do |semester|
          expect(semester[:hasEnrolledClasses]).to be true
        end
      end
    end
  end

  describe 'merging grade data' do
    before do
      allow(Settings.terms).to receive(:fake_now).and_return(fake_now)
      allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
    end

    let(:term_yr) { '2016' }
    let(:term_cd) { 'B' }
    let(:enrollment_data) { generate_enrollment_data  }
    let(:feed_semester) { feed[:semesters].find { |s| s[:name] == Berkeley::TermCodes.to_english(term_yr, term_cd) } }
    let(:feed_semester_grades) { feed_semester[:classes].map { |course| course[:sections].map {|s| s[:grading] if s[:is_primary_section]}.compact }.flatten! }

    shared_examples 'grades from enrollment' do
      it 'returns enrollment grades' do
        grades_from_enrollment = enrollment_data["#{term_yr}-#{term_cd}"].map { |e| e[:sections].map{ |s| s[:grading] if s[:is_primary_section] }.compact }.flatten!
        expect(feed_semester_grades).to match_array grades_from_enrollment
      end
    end

    shared_examples 'grading in progress' do
      it { expect(feed_semester[:gradingInProgress]).to be_truthy }
    end

    shared_examples 'grading not in progress' do
      it { expect(feed_semester[:gradingInProgress]).to be_nil }
    end

    context 'current semester' do
      let(:fake_now) {DateTime.parse('2016-04-10')}
      include_examples 'grades from enrollment'
      include_examples 'grading not in progress'
    end

    context 'semester just ended' do
      let(:fake_now) {DateTime.parse('2016-05-22')}
      include_examples 'grades from enrollment'
      include_examples 'grading in progress'
    end

    context 'past semester' do
      let(:fake_now) {DateTime.parse('2016-08-10')}
      include_examples 'grading not in progress'
    end
  end

  context 'filtered view for delegate' do
    def enrollment_summary_term(key)
      rand(2..4).times.map { enrollment_summary(key) }
    end

    def enrollment_summary(key)
      enrollment = course_enrollment key
      enrollment[:sections].map! { |section| section.except(:instructors, :schedules) }
      enrollment
    end

    let(:feed) { {filteredForDelegate: true}.tap { |feed| MyAcademics::Semesters.new(random_id).merge(feed) } }
    let(:enrollment_data) { generate_enrollment_data }
    let(:enrollment_summary_data) { Hash[term_keys.map{|key| [key, enrollment_summary_term(key)]}] }
    before do
      allow(Settings.terms).to receive(:legacy_cutoff).and_return 'summer-2014'
      allow_any_instance_of(EdoOracle::UserCourses::All).to receive(:get_enrollments_summary).and_return enrollment_summary_data
    end

    include_examples 'semester ordering'

    it 'should preserve structure of enrollment summary data' do
      feed[:semesters].each do |s|
        expect(s[:hasEnrollmentData]).to eq true
        expect(s).to include :slug
        enrollment_semester = enrollment_summary_data["#{s[:termYear]}-#{s[:termCode]}"]
        expect(s[:classes].length).to eq enrollment_semester.length
        s[:classes].each do |course|
          matching_enrollment = enrollment_semester.find { |e| e[:id] == course[:course_id] }
          expect(course[:sections].count).to eq matching_enrollment[:sections].count
          expect(course[:title]).to eq matching_enrollment[:name]
          expect(course[:courseCatalog]).to eq matching_enrollment[:course_catalog]
          [:course_code, :dept, :dept_desc, :role, :slug, :session_code].each do |key|
            expect(course[key]).to eq matching_enrollment[key]
          end
        end
      end
    end

    it 'should filter out course URLs' do
      feed[:semesters].each do |s|
        s[:classes].each do |course|
          expect(course).not_to include :url
        end
      end
    end

    it 'should flag it as filtered for delegate' do
      feed[:semesters].each do |s|
        expect(s[:filteredForDelegate]).to eq true
      end
    end

  end
end
