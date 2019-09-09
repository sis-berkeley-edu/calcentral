describe MediacastsController do

  let(:params) {
    {
      term_yr: course[:term_yr],
      term_cd: course[:term_cd],
      dept_name: course[:dept_name],
      catalog_id: course[:catalog_id]
    }
  }
  before do
    session['user_id'] = random_id
    allow(Settings.webcast_proxy).to receive(:fake).and_return true
  end

  shared_examples 'a course with recordings' do
    before do
      sections_instructing = [
        {
          classes: [
            {
              sections: [
                {
                  ccn: expected_ccn.to_s,
                  section_number: random_id,
                  instruction_format: 'LEC'
                }
              ]
            }
          ]
        }
      ]
      expect(MyAcademics::Teaching).to receive(:new).and_return (model = double)
      expect(model).to receive(:courses_list_from_ccns).once.and_return sections_instructing
      term = "#{course[:term_yr]}-#{course[:term_cd]}"
      courses = {
        term => [
          {
            dept: course[:dept_name],
            catid: course[:catalog_id],
            sections: [
              {
                ccn: expected_ccn.to_s,
                section_number: random_id,
                instruction_format: 'LEC'
              }
            ]
          }
        ]
      }
      expect(EdoOracle::UserCourses::All).to receive(:new).and_return (edo = double)
      expect(edo).to receive(:all_campus_courses).once.and_return courses
    end
    it 'should have video' do
      get :get_media, params
      expect(response).to be_success
      media = JSON.parse(response.body)['media'][0]
      expect(media['ccn']).to eq expected_ccn
      expect(media['videos']).to eq expected_videos
    end
  end

  context 'course with recordings' do
    it_should_behave_like 'a course with recordings' do
      let(:astro_ccn_with_recordings) { 30598 }
      let(:course) {
        {
          term_yr: '2016',
          term_cd: 'D',
          dept_name: 'XASTRON',
          catalog_id: '10',
          ccn_set: [ astro_ccn_with_recordings ]
        }
      }
      let(:expected_ccn) { astro_ccn_with_recordings.to_s }
      let(:expected_videos) {
        [
          {
            'lecture' => '2016-08-25: A Grand Tour of the Cosmos',
            'youTubeId' => 'E8WBr8u7YoI',
            'recordingStartUTC' => '2015-08-25T15:07:00-08:00'
          }
        ]
      }
    end
  end

end
