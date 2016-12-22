describe MyAcademics::Teaching do

  before do
    allow(Settings.features).to receive(:hub_term_api).and_return false
  end

  let(:feed) { {}.tap { |feed| described_class.new(uid).merge feed } }
  let(:teaching) { feed[:teachingSemesters] }

  shared_examples 'a properly translated feed' do
    it 'should properly translate semesters' do
      expect(teaching).to have(2).items
      expect(teaching.first).to include({
        name: 'Fall 2013',
        termCode: 'D',
        termYear: '2013'
      })
    end
    it 'should properly translate sample BIOLOGY course' do
      expect(teaching[0][:classes]).to have(2).items
      bio1a = teaching[0][:classes].find { |course| course[:listings].first[:course_code] == 'BIOLOGY 1A' }
      expect(bio1a).to include({
        title: 'General Biology Lecture',
        role: 'Instructor'
      })
      expect(bio1a[:listings]).to have(1).items
      expect(bio1a[:listings].first[:dept]).to eq 'BIOLOGY'
      # Redundant fields to keep parity with student semesters feed structure
      expect(bio1a).to include({
        courseCatalog: '1A',
        course_code: 'BIOLOGY 1A',
        course_id: 'biology-1a-2013-D',
        dept: 'BIOLOGY'
      })
      expect(bio1a[:url]).to eq '/academics/teaching-semester/fall-2013/class/biology-1a'
    end
    it 'should properly translate sample COG SCI course' do
      cogsci = teaching[0][:classes].find {|course| course[:listings].find {|listing| listing[:course_code] == 'COG SCI C147'}}
      expect(cogsci).not_to be_empty
      expect(cogsci).to include({
        title: 'Language Disorders',
        url: '/academics/teaching-semester/fall-2013/class/cog_sci-c147'
      })
      expect(cogsci[:listings].map {|listing| listing[:dept]}).to include 'COG SCI'
    end
    it 'should properly translate section-level data' do
      bio1a = teaching[0][:classes].find { |course| course[:listings].first[:course_code] == 'BIOLOGY 1A' }
      expect(bio1a[:scheduledSectionCount]).to eq 3
      expect(bio1a[:scheduledSections]).to include({format: 'lecture', count: 1})
      expect(bio1a[:scheduledSections]).to include({format: 'discussion', count: 2})
      expect(bio1a[:sections]).to have(3).items
      expect(bio1a[:sections][0][:is_primary_section]).to eq true
      expect(bio1a[:sections][1][:is_primary_section]).to eq false
      expect(bio1a[:sections][2][:is_primary_section]).to eq false
    end
    it 'should let the past be the past' do
      expect(teaching[1][:name]).to eq 'Spring 2012'
      expect(teaching[1][:classes]).to have(2).items
      expect(teaching[1][:timeBucket]).to eq 'past'
    end
  end

  context 'legacy academic data', if: CampusOracle::Connection.test_data? do
    before { allow(Settings.terms).to receive(:legacy_cutoff).and_return 'summer-2014' }
    let(:uid) { '238382' }
    it_should_behave_like 'a properly translated feed'
    it 'advertises legacy source' do
      expect(teaching).to all include({campusSolutionsTerm: false})
    end

    context 'user with future teaching assignments' do
      let(:uid) { '904715' }
      it 'should get correct time buckets' do
        expect(teaching).to have(2).items
        expect(teaching[0]).to include({
          name: 'Summer 2014',
          timeBucket: 'future'
        })
        expect(teaching[1]).to include({
          name: 'Fall 2013',
          timeBucket: 'current'
        })
      end
    end

    context 'cross-listed courses' do
      include_context 'instructor for crosslisted courses'
      let(:uid) { instructor_id }
      subject { teaching.first[:classes] }
      it_should_behave_like 'a feed including crosslisted courses'
    end
  end

  context 'academic data from Campus Solutions' do
    before do
      allow(Settings.terms).to receive(:legacy_cutoff).and_return 'fall-2009'
      expect(EdoOracle::UserCourses::All).to receive(:new).and_return double(get_all_campus_courses: edo_courses)
      expect(CampusOracle::Queries).not_to receive :get_instructing_sections
    end
    let(:uid) { '242881' }
    let(:edo_courses) do
      {
        '2013-D' => [
          {
            id: 'biology-1a-2013-D',
            slug: 'biology-1a',
            course_code: 'BIOLOGY 1A',
            term_yr: '2013',
            term_cd: 'D',
            term_id: '2138',
            dept: 'BIOLOGY',
            catid: '1A',
            course_catalog: '1A',
            emitter: 'Campus',
            name: 'General Biology Lecture',
            sections: [
              {
                ccn: '07309',
                enroll_limit: 50,
                instruction_format: 'LEC',
                is_primary_section: true,
                schedules: {oneTime: [], recurring: []},
                section_label: 'LEC 003',
                section_number: '003',
                waitlist_limit: 10
              },
              {
                ccn: '07366',
                enroll_limit: 25,
                instruction_format: 'DIS',
                is_primary_section: false,
                schedules: {oneTime: [], recurring: []},
                section_label: 'DIS 201',
                section_number: '201',
                waitlist_limit: 5
              },
              {
                ccn: '07372',
                enroll_limit: 25,
                instruction_format: 'DIS',
                is_primary_section: false,
                schedules: {oneTime: [], recurring: []},
                section_label: 'DIS 202',
                section_number: '202',
                waitlist_limit: 5
              }
            ],
            session_code: nil,
            role: 'Instructor',
            enroll_limit: 50,
            waitlist_limit: 10
          },
          {
            id: 'sumerian-c147-2013-D',
            slug: 'sumerian-c147',
            course_code: 'SUMERIAN C147',
            term_yr: '2013',
            term_cd: 'D',
            term_id: '2138',
            dept: 'SUMERIAN',
            catid: 'C147',
            course_catalog: 'C147',
            emitter: 'Campus',
            name: nil,
            sections: [
              {
                ccn: '10171',
                enroll_limit: 30,
                instruction_format: 'LEC',
                is_primary_section: true,
                schedules: {oneTime: [], recurring: []},
                section_label: 'LEC 001',
                section_number: '001',
                waitlist_limit: 0,
                cross_listing_hash: '2138-12345-LEC-001'
              }
            ],
            session_code: nil,
            role: 'Instructor',
            enroll_limit: 30,
            waitlist_limit: 0
          },
          {
            id: 'cog_sci-c147-2013-D',
            slug: 'cog_sci-c147',
            course_code: 'COG SCI C147',
            term_yr: '2013',
            term_cd: 'D',
            term_id: '2138',
            dept: 'COG SCI',
            catid: 'C147',
            course_catalog: 'C147',
            emitter: 'Campus',
            name: 'Language Disorders',
            sections: [
              {
                ccn: '16171',
                instruction_format: 'LEC',
                is_primary_section: true,
                schedules: {oneTime: [], recurring: []},
                section_label: 'LEC 001',
                section_number: '001',
                enroll_limit: 30,
                waitlist_limit: 0,
                cross_listing_hash: '2138-12345-LEC-001'
              }
            ],
            session_code: nil,
            role: 'Instructor',
            enroll_limit: 30,
            waitlist_limit: 0
          }
        ],
        '2012-B' => [
          {
            id: 'biology-1a-2012-B',
            slug: 'biology-1a',
            course_code: 'BIOLOGY 1A',
            term_yr: '2012',
            term_cd: 'B',
            term_id: '2122',
            dept: 'BIOLOGY',
            catid: '1A',
            course_catalog: '1A',
            emitter: 'Campus',
            name: 'General Biology Lecture',
            sections: [
              {
                ccn: '07366',
                enroll_limit: 25,
                instruction_format: 'DIS',
                is_primary_section: false,
                schedules: {oneTime: [], recurring: []},
                section_label: 'DIS 201',
                section_number: '201',
                waitlist_limit: 5,
              }
            ],
            session_code: nil,
            role: 'Instructor'
          },
          {
            id: 'cog_sci-c147-2012-B',
            slug: 'cog_sci-c147',
            course_code: 'COG SCI C147',
            term_yr: '2012',
            term_cd: 'B',
            term_id: '2122',
            dept: 'COG SCI',
            catid: 'C147',
            course_catalog: 'C147',
            emitter: 'Campus',
            name: 'Language Disorders',
            sections: [
              {
                ccn: '16171',
                instruction_format: 'LEC',
                is_primary_section: true,
                schedules: {oneTime: [], recurring: []},
                section_label: 'LEC 001',
                section_number: '001',
                enroll_limit: 30,
                waitlist_limit: 0
              }
            ],
            session_code: nil,
            role: 'Instructor',
            enroll_limit: 30,
            waitlist_limit: 0
          }
        ]
      }
    end
    it_should_behave_like 'a properly translated feed'
    it 'advertises Campus Solutions source' do
      expect(teaching).to all include({campusSolutionsTerm: true})
    end
    it 'merges cross-listings preserving course title' do
      language_disorders = teaching[0][:classes].find { |course| course[:title] == 'Language Disorders' }
      expect(language_disorders[:listings].map { |listing| listing[:dept]}).to match_array ['COG SCI', 'SUMERIAN']
      expect(language_disorders[:sections].map { |section| section[:ccn]}).to match_array %w(10171 16171)
    end
    it 'translates enrollment and waitlist limits' do
      bio1a = teaching[0][:classes].find { |course| course[:listings].first[:course_code] == 'BIOLOGY 1A' }
      expect(bio1a[:enrollLimit]).to eq 50
      expect(bio1a[:waitlistLimit]).to eq 10
    end
  end

  describe '#courses_list_from_ccns' do
    subject do
      MyAcademics::Teaching.new(random_id).courses_list_from_ccns(term[:yr], term[:cd], (good_ccns + bad_ccns))
    end
    let(:good_ccns) { ['07309', '07366', '16171'] }
    let(:bad_ccns) { ['919191'] }
    # Lock down to a known set of sections, either in the test DB or in real campus data.
    shared_examples 'a good and proper section formatting' do
      it 'formats section information for known CCNs' do
        expect(subject.length).to eq 1
        classes_list = subject[0][:classes]
        expect(classes_list.length).to eq 2
        bio_class = classes_list[0]
        expect(bio_class[:course_code]).to eq 'BIOLOGY 1A'
        expect(bio_class[:sections].first[:courseCode]).to eq 'BIOLOGY 1A'
        expect(bio_class[:dept]).to eq 'BIOLOGY'
        sections = bio_class[:sections]
        expect(sections.length).to eq 2
        expect(sections[0][:ccn].to_i).to eq 7309
        expect(sections[0][:section_label]).to eq 'LEC 003'
        expect(sections[0][:is_primary_section]).to be_truthy
        expect(sections[1][:ccn].to_i).to eq 7366
        expect(sections[1][:is_primary_section]).to be_falsey
        cog_sci_class = classes_list[1]
        sections = cog_sci_class[:sections]
        expect(sections.length).to eq 1
        expect(sections[0][:ccn].to_i).to eq 16171
      end
    end

    context 'legacy term data' do
      before do
        allow(Settings.terms).to receive(:legacy_cutoff).and_return 'fall-2013'
        expect(EdoOracle::UserCourses::SelectedSections).not_to receive :new
      end
      let(:term) {
        CampusOracle::Connection.test_data? ?  {yr: '2013', cd: 'D'} : {yr: '2013', cd: 'B'}
      }
      include_examples 'a good and proper section formatting'
    end

    context 'Campus Solutions term data' do
      before do
        allow(Settings.terms).to receive(:legacy_cutoff).and_return 'fall-2009'
        expect(EdoOracle::UserCourses::SelectedSections).to receive(:new).and_return double(get_selected_sections: edo_courses)
        expect(CampusOracle::UserCourses::SelectedSections).not_to receive :new
      end
      let(:term) { {yr: '2013', cd: 'D'} }
      let(:edo_courses) do
        {
          '2013-D' => [
            {
              id: 'biology-1a-2013-D',
              slug: 'biology-1a',
              course_code: 'BIOLOGY 1A',
              term_yr: '2013',
              term_cd: 'D',
              term_id: '2138',
              dept: 'BIOLOGY',
              catid: '1A',
              course_catalog: '1A',
              emitter: 'Campus',
              name: 'General Biology Lecture',
              sections: [
                {
                  ccn: '07309',
                  instruction_format: 'LEC',
                  is_primary_section: true,
                  schedules: {oneTime: [], recurring: []},
                  section_label: 'LEC 003',
                  section_number: '003'
                },
                {
                  ccn: '07366',
                  instruction_format: 'DIS',
                  is_primary_section: false,
                  schedules: {oneTime: [], recurring: []},
                  section_label: 'DIS 201',
                  section_number: '201'
                }
              ],
              role: 'Instructor'
            },
            {
              id: 'cog_sci-c147-2013-D',
              slug: 'cog_sci-c147',
              course_code: 'COG SCI C147',
              term_yr: '2013',
              term_cd: 'D',
              term_id: '2138',
              dept: 'COG SCI',
              catid: 'C147',
              course_catalog: 'C147',
              emitter: 'Campus',
              name: 'Language Disorders',
              sections: [
                {
                  ccn: '16171',
                  instruction_format: 'LEC',
                  is_primary_section: true,
                  schedules: {oneTime: [], recurring: []},
                  section_label: 'LEC 001',
                  section_number: '001'
                }
              ],
              role: 'Instructor'
            }
          ]
        }
      end
      include_examples 'a good and proper section formatting'
    end
  end
end
