class PhotoController < ApplicationController
  before_action :api_authenticate_401

  def my_photo
    send_photo get_photo(session['user_id'])
  end

  def photo
    if current_user.policy.can_view_other_user_photo?
      send_photo get_photo(uid_param)
    else
      head :forbidden
    end
  end

  def get_photo(uid)
    photo_feed = User::Photo.fetch uid, session
    photo_feed.try(:[], :photo)
  end

  def send_photo(data)
    if data
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
      head :ok
    end
  end

  def uid_param
    params.require(:uid)
  end

end
