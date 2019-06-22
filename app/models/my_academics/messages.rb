module MyAcademics
  class Messages

    def initialize(uid)
      @uid = uid
    end

    def merge(data)
      data[:messages] = get_messages
    end

    def get_messages
      CampusSolutions::MessageCatalog.get_message_collection([
        :waitlisted_units_warning
      ])
    end
  end
end
