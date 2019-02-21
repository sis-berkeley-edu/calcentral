module CalGrant
  module AcknowledgementExpiry
    def self.expire(uid=nil)
      CalGrant::Acknowledgement.expire uid
      MyAcademics::MyHolds.expire uid
      MyAcademics::MyAcademicStatus.expire uid
      MyAcademics::ClassEnrollments.expire uid
    end
  end
end
