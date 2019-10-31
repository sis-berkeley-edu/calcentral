module CampusSolutions
  module UserApiExpiry
    def self.expire(uid=nil)
      HubEdos::PersonApi::V1::SisPerson.expire uid
      HubEdos::MyStudent.expire uid
      HubEdos::StudentApi::V2::Contacts.expire uid
      HubEdos::StudentApi::V2::Demographics.expire uid
      HubEdos::StudentApi::V2::Gender.expire uid
      HubEdos::StudentApi::V2::StudentAttributes.expire uid
      HubEdos::StudentApi::V2::WorkExperiences.expire uid
      User::Api.expire uid
    end
  end
end
