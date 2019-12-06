class RostersController < ApplicationController
  include ClassLogger

  def serve_photo
    if (@photo.nil?)
      head :unauthorized
    elsif (data = @photo[:data])
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
            @photo[:filename],
            type: 'image/jpeg',
            disposition: 'inline'
          )
        }
      end
    end
  end

end
