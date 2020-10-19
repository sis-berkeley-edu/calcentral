class MyCommitteesController < ApplicationController

  before_action :api_authenticate
  rescue_from StandardError, with: :handle_api_exception

  def get_feed
    render :json => MyCommittees::Merged.from_session(session).get_feed_as_json
  end

  def student_photo
    student_id = Integer(params['student_id'], 10)
    my_committees = MyCommittees::Merged.from_session(session)
    my_committees_feed = my_committees.get_feed_as_json
    if my_committees_feed.include? "student/#{student_id}"
      student_photo = my_committees.photo_data_or_file(student_id)
      serve_photo(student_photo)
    else
      head :forbidden
    end
  end

  def member_photo
    member_id = Integer(params['member_id'], 10) if params['member_id']
    my_committees = MyCommittees::Merged.from_session(session)
    my_committees_feed = my_committees.get_feed_as_json
    if member_id && (my_committees_feed.include? "member/#{member_id}")
      member_photo = my_committees.photo_data_or_file(member_id)
      serve_photo(member_photo)
    else
      head :forbidden
    end
  end

  def serve_photo (person_photo)
    if person_photo.nil?
      head :ok
    elsif (data = person_photo[:data])
      respond_to do |format|
        format.jpeg {
          send_data(
            data,
            type: 'image/jpeg',
            disposition: 'inline'
          )
        }
      end
    else
      respond_to do |format|
        format.jpeg {
          send_file(
            person_photo[:filename],
            type: 'image/jpeg',
            disposition: 'inline'
          )
        }
      end
    end
  end

end
