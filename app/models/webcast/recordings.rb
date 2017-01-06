module Webcast
  class Recordings < Proxy

    def get_json_path
      'warehouse/webcast.json'
    end

    def request_internal
      return {} unless Settings.features.videos

      recordings = {
        courses: {}
      }
      get_json_data['courses'].each do |course|
        year = course['year']
        semester = course['semester']
        ccn = course['ccn']
        if year && semester && ccn
          key = Webcast::CourseMedia.id_per_ccn(year, semester, course['ccn'])
          recordings[:courses][key] = {
            recordings: course['recordings'],
            youtube_playlist: course['youTubePlaylist']
          }
        end
      end
      recordings
    end

  end
end
