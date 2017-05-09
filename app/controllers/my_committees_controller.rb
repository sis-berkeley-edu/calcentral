class MyCommitteesController < ApplicationController

  before_filter :api_authenticate
  rescue_from StandardError, with: :handle_api_exception

  def get_feed
    render :json => MyCommittees::Merged.from_session(session).get_feed_as_json
  end

  def student_photo
    student_id = Integer(params['student_id'], 10)
    my_committees = MyCommittees::Merged.from_session(session)
    if my_committees.get_feed_as_json.include? "student/#{student_id}"
      student_photo = my_committees.photo_data_or_file(student_id)
      serve_photo(student_photo)
    else
      render :nothing => true, :status => 403
    end
  end

  def member_photo
    member_id = Integer(params['member_id'], 10) if params['member_id']
    my_committees = MyCommittees::Merged.from_session(session)
    if  member_id && (my_committees.get_feed_as_json.include? "member/#{member_id}")
      member_photo = my_committees.photo_data_or_file(member_id)
      serve_photo(member_photo)
    else
      render :nothing => true, :status => 403
    end
  end

  def serve_photo (person_photo)
    if person_photo.nil?
      render :nothing => true, :status => 200
    elsif (data = person_photo[:data])
      send_data(
        data,
        type: 'image/jpeg',
        disposition: 'inline'
      )
    else
      send_file(
        person_photo[:filename],
        type: 'image/jpeg',
        disposition: 'inline'
      )
    end
  end

end
