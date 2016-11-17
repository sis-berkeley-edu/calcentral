module CampusSolutions
  class CsOfficialTranscriptController < CampusSolutionsController

    def get
      render json: CampusSolutions::MyCsOfficialTranscript.from_session(session).get_feed_as_json
    end

  end
end
