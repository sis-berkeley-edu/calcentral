module CalnetLdap
  # https://calnetweb.berkeley.edu/calnet-technologists/ldap-directory-service/how-ldap-organized/people-ou
  class Person
    def self.get(user)
      if net_ldap_entry = CalnetLdap::Client.new.search_by_uid(user.uid)
        return self.new(net_ldap_entry)
      end
      nil
    end

    def initialize(net_ldap_entry)
      @net_ldap_entry = net_ldap_entry
    end

    # CalNet Uid
    def uid
      @net_ldap_entry[:uid].first
    end

    # Berkeley Campus Student ID
    def student_id
      @net_ldap_entry[:berkeleyedustuid].first
    end

    # Berkeley Campus Solutions ID
    def campus_solutions_id
      @net_ldap_entry[:berkeleyeducsid].first
    end

    # Email Address (if provided by user)
    def email
      @net_ldap_entry[:mail].first
    end

    # Given (first + middle) Name
    def given_name
      @net_ldap_entry[:givenname].first
    end

    # Surname (last name)
    def surname
      @net_ldap_entry[:sn].first
    end

    # common (full) name
    def common_name
      @net_ldap_entry[:cn].first
    end

    # Preferred Display Name
    def display_name
      @net_ldap_entry[:displayname].first
    end

    # Official Berkeley Email Address
    def official_email
      @net_ldap_entry[:berkeleyeduofficialemail].first
    end

    # Confidential Flag
    def confidential_flag
      @net_ldap_entry[:berkeleyeduconfidentialflag].first == 'true'
    end

    # Berkeley Campus General Affiliations
    def affiliations
      @net_ldap_entry[:berkeleyeduaffiliations]
    end
  end
end
