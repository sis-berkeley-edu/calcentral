describe MyClasses::Campus do
  before do
    allow(Settings.features).to receive(:hub_term_api).and_return false
  end
  let(:user_id) {rand(99999).to_s}
  let(:catid) {"#{rand(999)}B"}
  let(:course_code) { "ECON #{catid}" }
  let(:course_id) {"econ-#{catid}-#{term_yr}-#{term_cd}"}
  let(:term_yr) {2013}
  let(:term_cd) {'D'}
  let(:fake_sections) {[
    {
      ccn: rand(99999),
      instruction_format: 'LEC',
      is_primary_section: true
    }
  ]}
  let(:fake_campus_course) {{
    id: course_id,
    term_yr: term_yr,
    term_cd: term_cd,
    catid: catid,
    dept: 'ECON',
    course_code: course_code,
    course_option: 'E1',
    emitter: 'Campus',
    name: 'Retire in Only 85 Years',
    role: 'Student',
    sections: fake_sections
  }}
  let(:fake_legacy_feed) do
    {
      "#{term_yr}-#{term_cd}" => [fake_campus_course]
    }
  end
  let(:fake_edo_feed) do
    {
      "#{term_yr}-#{term_cd}" => [fake_campus_course.except(:course_option)]
    }
  end

  shared_context 'legacy source' do
    before do
      allow(Settings.terms).to receive(:legacy_cutoff).and_return 'fall-2014'
      expect(CampusOracle::UserCourses::All).to receive(:new).with(user_id: user_id).at_least(1).times.and_return double(get_all_campus_courses: fake_legacy_feed)
    end
  end

  shared_context 'Campus Solutions source' do
    before do
      allow(Settings.terms).to receive(:legacy_cutoff).and_return 'spring-2013'
      expect(EdoOracle::UserCourses::All).to receive(:new).with(user_id: user_id).at_least(1).times.and_return double(all_campus_courses: fake_edo_feed)
    end
  end

  shared_examples 'a Classes list' do
    its(:size) {should > 0}
    it 'sets the usual fields' do
      subject.each do |course|
        expect(course[:emitter]).to eq CampusOracle::UserCourses::APP_ID
        expect(course[:listings].length).to eq 1
        expect(course[:listings].first[:catid]).to eq catid
        expect(course[:listings].first[:course_code]).to eq course_code
        expect(course[:site_url]).to be_present
        expect(course[:sections]).to_not be_empty
      end
    end
  end

  describe '#fetch' do
    let(:campus_classes) { MyClasses::Campus.new(user_id).fetch }
    shared_examples 'a classes list properly grounded in time' do
      context 'when enrolled in a current class' do
        subject { campus_classes[:current] }
        it_behaves_like 'a Classes list'
        it 'omits grading in progress classes' do
          expect(campus_classes).not_to include :gradingInProgress
        end
      end
      context 'when enrolled in a non-current term' do
        let(:term_yr) {2012}
        it 'lists no current classes' do
          expect(campus_classes[:current]).to be_empty
        end
      end
    end
    context 'legacy term data' do
      include_context 'legacy source'
      it_should_behave_like 'a classes list properly grounded in time'
    end
    context 'Campus Solutions term data' do
      include_context 'Campus Solutions source'
      it_should_behave_like 'a classes list properly grounded in time'
    end

    context 'when student in two primary sections with the same department and catalog ID' do
      shared_examples 'a good and proper munging' do
        it_behaves_like 'a Classes list'
        its(:size) {should eq 2}
        it 'treats them as two different classes' do
          expect(subject[0][:listings][0][:id]).to_not eq subject[1][:listings][0][:id]
          expect(subject[0][:site_url]).to_not eq subject[1][:site_url]
          [subject, fake_sections[0..1]].transpose.each do |course, enrollment|
            expect(course[:listings].first[:courseCodeSection]).to eq "#{enrollment[:instruction_format]} #{enrollment[:section_number]}"
            expect(course[:sections][0][:ccn]).to eq enrollment[:ccn]
            if (enrollment[:waitlisted])
              expect(course[:enroll_limit]).to eq enrollment[:enroll_limit]
              expect(course[:waitlistPosition]).to eq enrollment[:waitlistPosition]
            end
          end
        end
        it 'associates secondary sections with correct primary' do
          expect(subject[0][:sections].size).to eq 2
          expect(subject[1][:sections].size).to eq 1
        end
      end
      subject { campus_classes[:current] }

      context 'legacy section data' do
        include_context 'legacy source'
        let(:fake_sections) {[
          {
            ccn: '76378',
            enroll_status: 'E',
            instruction_format: 'FLD',
            is_primary_section: true,
            pnp_flag: 'Y ',
            unit: '3',
            section_number: '012',
            waitlistPosition: 0
          },
          {
            ccn: '76392',
            enroll_status: 'W',
            enroll_limit: 20,
            instruction_format: 'FLD',
            is_primary_section: true,
            pnp_flag: 'N ',
            unit: '2',
            section_number: '021',
            waitlisted: true,
            waitlistPosition: 2
          },
          {
            ccn: '76393',
            enroll_status: 'E',
            instruction_format: 'DIS',
            is_primary_section: false,
            pnp_flag: 'N ',
            unit: '0',
            section_number: '200',
            waitlisted: true,
            waitlistPosition: 0
          }
        ]}
        it_should_behave_like 'a good and proper munging'
      end

      context 'Campus Solutions section data' do
        include_context 'Campus Solutions source'
        let(:fake_sections) {[
          {
            ccn: '76378',
            enroll_status: 'E',
            grading_basis: 'PNP',
            instruction_format: 'FLD',
            is_primary_section: true,
            pnp_flag: 'Y ',
            unit: '3',
            section_number: '012',
            waitlistPosition: 0
          },
          {
            ccn: '76392',
            enroll_status: 'W',
            enroll_limit: 20,
            grading_basis: 'GRD',
            instruction_format: 'FLD',
            is_primary_section: true,
            unit: '2',
            section_number: '021',
            waitlisted: true,
            waitlistPosition: 2
          },
          {
            associated_primary_id: '76378',
            ccn: '76393',
            enroll_status: 'E',
            grading_basis: 'GRD',
            instruction_format: 'DIS',
            is_primary_section: false,
            pnp_flag: 'N ',
            unit: '0',
            section_number: '200',
            waitlistPosition: 0
          }
        ]}
        it_should_behave_like 'a good and proper munging'
      end
    end

    context 'when term has just ended' do
      before { allow(Settings.terms).to receive(:fake_now).and_return(DateTime.parse('2013-12-30')) }
      subject { campus_classes[:gradingInProgress] }
      context 'legacy term data' do
        include_context 'legacy source'
        it 'includes empty current term' do
          expect(campus_classes[:current]).to be_empty
        end
        it_behaves_like 'a Classes list'
      end
      context 'Campus Solutions term data' do
        include_context 'Campus Solutions source'
        it 'includes empty current term' do
          expect(campus_classes[:current]).to be_empty
        end
        it_behaves_like 'a Classes list'
      end
    end
  end

  context 'cross-listed courses', if: CampusOracle::Connection.test_data? do
    include_context 'instructor for crosslisted courses'
    subject { MyClasses::Campus.new('212388').fetch[:current] }
    it_should_behave_like 'a feed including crosslisted courses'
  end
end
