module HubEdos
  class MyStudentAttributes < UserSpecificModel

    def get_feed_internal
      HubEdos::StudentAttributes.new({user_id: @uid}).get
    end

  end
end
