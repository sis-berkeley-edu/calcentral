class MyLawAwardsController < ApplicationController
  def get_feed
    render json: HashConverter.camelize({
      awards: MyAcademics::Law::Awards.new(user_id).awards,
      transcript_notes: MyAcademics::Law::TranscriptNotes.new(user_id).notes,
    })
  end

  private

  def user_id
    session['user_id']
  end
end
