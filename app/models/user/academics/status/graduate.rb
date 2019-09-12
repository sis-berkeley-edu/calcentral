module User
  module Academics
    module Status
      class Graduate < Postgraduate
        def enrolled?
          registration_records.find(&:graduate?).enrolled?
        end
      end
    end
  end  
end
