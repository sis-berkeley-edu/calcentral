module CampusSolutions
  module PersonDataExpiry
    def self.expire(uid=nil)
      HubEdos::MyStudent.expire uid
      HubEdos::Affiliations.expire uid
      HubEdos::Contacts.expire uid
      HubEdos::Demographics.expire uid
    end
  end
end
