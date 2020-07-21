module CampusSolutions
  module UserApiExpiry
    def self.expire(uid=nil)
      HubEdos::PersonApi::V1::SisPerson.expire uid
      HubEdos::MyStudent.expire uid
      HubEdos::StudentApi::V2::Feeds::Contacts.expire uid
      HubEdos::StudentApi::V2::Feeds::Demographics.expire uid
      HubEdos::StudentApi::V2::Feeds::Gender.expire uid
      HubEdos::StudentApi::V2::Feeds::StudentAttributes.expire uid
      HubEdos::StudentApi::V2::Feeds::WorkExperiences.expire uid
      User::Api.expire uid
    end
  end
end
