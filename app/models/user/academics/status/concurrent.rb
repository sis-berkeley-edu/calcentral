module User
  module Academics
    module Status
      class Concurrent < Base
        delegate :message, :severity, :detailed_message_html, :to => :prioritized_status

        private

        def prioritized_status
          [law_status, graduate_status].sort.first
        end

        def law_status
          User::Academics::Status::Law.new(__getobj__)
        end

        def graduate_status
          User::Academics::Status::Graduate.new(__getobj__)
        end
      end
    end
  end
end
