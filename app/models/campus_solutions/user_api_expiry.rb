module CampusSolutions
  module UserApiExpiry
    def self.expire(uid=nil)
      HubEdos::StudentApi::V1::MyStudent.expire uid
      HubEdos::StudentApi::V1::Affiliations.expire uid
      HubEdos::StudentApi::V1::Contacts.expire uid
      HubEdos::StudentApi::V1::Demographics.expire uid
      User::Api.expire uid
    end
  end
end
