module CampusSolutions
  module UserApiExpiry
    def self.expire(uid=nil)
      HubEdos::V1::MyStudent.expire uid
      HubEdos::V1::Affiliations.expire uid
      HubEdos::V1::Contacts.expire uid
      HubEdos::V1::Demographics.expire uid
      User::Api.expire uid
    end
  end
end
