module User
  module Academics
    module Status
      class Base < SimpleDelegator
        include ::User::Academics::Status::Messages
        include ::User::Academics::Status::Severity

        def message
        end

        def message_catalog(key)
          CampusSolutions::MessageCatalog.get_message(key)[:descrlong]
        end
      end
    end
  end
end
