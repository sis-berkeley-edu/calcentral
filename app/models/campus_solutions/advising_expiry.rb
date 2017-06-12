module CampusSolutions
  module AdvisingExpiry
    def self.expire(uid=nil)
      [Advising::MyAdvising].each do |klass|
        klass.expire uid
      end
    end
  end
end
