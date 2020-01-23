module User
  class Affiliations
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def matriculated_but_excluded?
      affiliations.find(&:matriculated_but_excluded?)
    end

    def not_registered?
      ldap_data.include? "STUDENT-TYPE-NOT REGISTERED"
    end

    def affiliations
      @affiliations ||= affiliations_data.collect do |affiliation|
        ::User::Affiliation.new(affiliation)
      end
    end

    def ldap_data
      @ldap_data ||= CalnetLdap::Client.new.search_by_uid(uid)[:berkeleyeduaffiliations] || []
    rescue NoMethodError
      []
    end

    private

    def uid
      user.uid
    end

    def affiliations_data
      @affiliations_data ||= HubEdos::PersonApi::V1::SisPerson.new(user_id: uid).get[:feed]["affiliations"] || []
    rescue NoMethodError
      []
    end
  end
end
