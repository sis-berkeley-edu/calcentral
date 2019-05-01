module User
  class Data < ActiveRecord::Base
    include ActiveRecordHelper, OraclePrimaryHelper

    self.table_name = 'PS_UC_USER_DATA'
    self.primary_key = 'uc_clc_id'

    has_many :saved_uids, :class_name => 'User::SavedUid', :foreign_key => 'uc_clc_oid'
    has_many :recent_uids, :class_name => 'User::RecentUid', :foreign_key => 'uc_clc_oid'

    after_initialize :log_access
    attr_accessible :uc_clc_prefnm, :uc_clc_ldap_uid, :uc_clc_fst_at, :uc_clc_id, :created_at, :updated_at
    attr_accessible :uid
    alias_attribute :uid, :uc_clc_ldap_uid
    alias_attribute :first_login_at, :uc_clc_fst_at
    alias_attribute :preferred_name, :uc_clc_prefnm

    def self.attributeDefaults
      {uc_clc_prefnm: ' '}
    end

    before_save :set_default_values
    before_create :set_id

    def self.database_alive?
      is_alive = false
      is_recoverable = false
      begin
        use_pooled_connection {
          if ENV["RAILS_ENV"]=='production' or (ENV["RAILS_ENV"]=='development' and Settings.devdb.adapter == 'oracle_enhanced')
            find_by_sql("select 1 from dual").first
          else
            find_by_sql("select 1").first
          end

          is_alive = true
        }
      rescue ActiveRecord::ActiveRecordError => exception
        if exception.message.include?('This connection has been closed')
          Rails.logger.warn("Attempting to reconnect to primary DB server...")
          is_recoverable = true


        else
          Rails.logger.warn("Primary DB server is down: #{exception}")
          is_alive = false
        end
      end
      if is_recoverable
        begin
          connection.reconnect!
          is_alive = true
        rescue Java::JavaSql::SQLException => reconnect_exception
          Rails.logger.warn("Primary DB server is still down: #{reconnect_exception}")
          is_alive = false
        end
      end
      is_alive
    end

  end
end
