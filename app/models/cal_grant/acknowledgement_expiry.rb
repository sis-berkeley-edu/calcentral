module CalGrant
  module AcknowledgementExpiry
    def self.expire(uid=nil)
      CalGrant::Acknowledgement.expire uid
    end
  end
end
