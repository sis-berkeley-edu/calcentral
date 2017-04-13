module CalnetLdap
  class UserAttributes < BaseProxy
    extend SafeUtf8Encoding
    include Cache::UserCacheExpiry

    def initialize(options = {})
      super(Settings.ldap, options)
    end

    def get_feed
      self.class.fetch_from_cache @uid do
        @fake ? {} : get_feed_internal
      end
    end

    def get_feed_internal
      if (result = CalnetLdap::Client.new.search_by_uid @uid)
        self.class.parse result
      else
        {}
      end
    end

    def self.get_feed_by_cs_id(cs_id)
      if (result = CalnetLdap::Client.new.search_by_cs_id cs_id)
        feed = parse result
      else
        feed = {}
      end
      write_cache(feed, feed[:ldap_uid])
      feed
    end

    def self.get_bulk_attributes(uids)
      CalnetLdap::Client.new.search_by_uids(uids).map do |result|
        feed = parse result
        write_cache(feed, feed[:ldap_uid])
        feed
      end
    end

    def self.get_attributes_by_name(name, include_guest_users=false)
      CalnetLdap::Client.new.search_by_name(name, include_guest_users).map do |result|
        feed = parse result
        write_cache(feed, feed[:ldap_uid])
        feed
      end
    end

    def self.parse(ldap_record)
      affiliation_roles = Berkeley::UserRoles.roles_from_ldap_affiliations ldap_record
      group_roles = Berkeley::UserRoles.roles_from_ldap_groups(ldap_record[:berkeleyeduismemberof])
      roles = group_roles.merge affiliation_roles
      roles[:confidential] = true if string_attribute(ldap_record, :berkeleyeduconfidentialflag) == 'true'
      identifiers(ldap_record).merge(
        email_address: string_attribute(ldap_record, :mail) || string_attribute(ldap_record, :berkeleyeduofficialemail),
        first_name: string_attribute(ldap_record, :berkeleyEduFirstName) || string_attribute(ldap_record, :givenname),
        last_name: string_attribute(ldap_record, :berkeleyEduLastName) || string_attribute(ldap_record, :sn),
        person_name: string_attribute(ldap_record, :displayname),
        roles: roles,
        official_bmail_address: string_attribute(ldap_record, :berkeleyeduofficialemail)
      )
    end

    def self.identifiers(ldap_record)
      sid = string_attribute(ldap_record, :berkeleyedustuid)
      cs_id = string_attribute(ldap_record, :berkeleyeducsid)
      ldap_uid = string_attribute(ldap_record, :uid)
      if sid.present? && cs_id.present? && sid != cs_id
        logger.warn "Conflicting berkeleyEduStuID #{sid} and berkeleyEduCSID #{cs_id} for UID #{ldap_uid}"
      end
      {
        ldap_uid: ldap_uid,
        student_id: sid,
        campus_solutions_id: cs_id
      }
    end

    def self.string_attribute(ldap_record, key)
      if (attribute = ldap_record[key].try(:first).try(:to_s))
        safe_utf8 attribute
      end
    end

  end
end
