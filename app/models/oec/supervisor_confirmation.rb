module Oec
  class SupervisorConfirmation < Worksheet

    def export_name
      'Report Viewers'
    end

    def headers
      %w(
        LDAP_UID
        FIRST_NAME
        LAST_NAME
        EMAIL_ADDRESS
        SUPERVISOR_GROUP
        PRIMARY_ADMIN
        SECONDARY_ADMIN
        DEPT_NAME_1
        DEPT_NAME_2
        DEPT_NAME_3
        DEPT_NAME_4
        DEPT_NAME_5
        DEPT_NAME_6
        DEPT_NAME_7
        DEPT_NAME_8
        DEPT_NAME_9
        DEPT_NAME_10
      )
    end

    validate('LDAP_UID') { |row| 'Non-numeric' unless row['LDAP_UID'] =~ /\A\d+\Z/ }

  end
end
