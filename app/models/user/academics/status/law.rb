module User
  module Academics
    module Status
      class Law < Postgraduate
        def enrolled?
          registration_records.find(&:law?).enrolled?
        end
      end
    end
  end  
end
