describe MyActivities::Webcasts do
  let(:uid) { random_id }
  let(:recordings_proxy) { Webcast::Recordings.new(fake: fake) }

  before {
    allow(Settings.terms).to receive(:fake_now).and_return '2017-01-18 04:20:00'
    allow(Berkeley::Terms).to receive(:fetch).and_return (terms = double)
    allow(terms).to receive(:current).and_return double(year: 2017, code: 'B')
    allow(terms).to receive(:campus).and_return({})
  }

  let(:activities) do
    activities = []
    described_class.append!(uid, activities)
    activities
  end

  shared_examples 'a feed with no webcast activities' do
    it 'should append nothing' do
      expect(activities).to be_empty
    end
  end

  shared_examples 'a feed with webcast activities' do
    it 'should include notifications' do
      expect(activities).not_to be_empty
    end

    it 'should include course and uid data' do
      expected_activity = {
        emitter: 'Course Captures',
        id: '',
        linkText: 'View recording',
        source: 'PB HLTH 142',
        summary: 'A new recording for your Spring 2017 course, Intro to Probability and Statistics, is now available.',
        type: 'webcast',
        title: 'Recording Available',
        user_id: uid
      }
      expect(activities).to all include expected_activity
    end

    it 'should include recording-specific URLs' do
      activities.each do |activity|
        expect(activity[:sourceUrl]).to match /academics.*pb_hlth-142\?video=.+/
        expect(activity[:url]).to eq activity[:sourceUrl]
      end
    end

    it 'should only include webcasts after cutoff date' do
      expect(activities.collect { |a| a[:date][:epoch] }).to all be > MyActivities::Merged.cutoff_date
    end
  end

  context 'fake webcast proxy' do
    let(:fake) { true }
    let(:term) { '2017-B' }
    let(:my_current_courses) {
      [
        {
          term_yr: 2017,
          term_cd: 'B',
          course_code: 'PB HLTH 142',
          slug: 'pb_hlth-142',
          name: 'Intro to Probability and Statistics',
          sections: sections
        }
      ]
    }

    before {
      allow(Webcast::Recordings).to receive(:new).and_return recordings_proxy
      expect(EdoOracle::UserCourses::All).to receive(:new).with(user_id: uid).once.and_return (queries = double)
      expect(queries).to receive(:get_all_campus_courses).and_return(term => my_current_courses)
    }

    context 'user enrolled or teaching a course with recordings' do
      let(:sections) {
        [
          ccn: '32502'
        ]
      }
      it_should_behave_like 'a feed with webcast activities'
    end

    context 'user neither teaching nor enrolled in a course with recordings' do
      let(:sections) {
        [
          ccn: '00000'
        ]
      }
      it_should_behave_like 'a feed with no webcast activities'
    end
  end

  context 'connection failure' do
    let(:fake) { false }
    before { stub_request(:any, /.*/).to_raise Errno::EHOSTUNREACH }
    after { WebMock.reset! }

    it_should_behave_like 'a feed with no webcast activities'
  end
end
