module User
  class Auth < ActiveRecord::Base
    include ActiveRecordHelper, OraclePrimaryHelper

    self.table_name = 'PS_UC_USER_AUTHS'
    self.primary_key = 'uc_clc_id'

    after_initialize :log_access
    attr_accessible :uid, :is_superuser, :is_author, :is_viewer, :active
    attr_accessible :uc_clc_id, :uc_clc_is_su, :uc_clc_is_au, :uc_clc_is_vw, :uc_clc_active

    alias_attribute :active, :uc_clc_active
    alias_attribute :is_viewer, :uc_clc_is_vw
    alias_attribute :is_superuser, :uc_clc_is_su
    alias_attribute :uid, :uc_clc_ldap_uid
    alias_attribute :is_author, :uc_clc_is_au

    if ENV["RAILS_ENV"]=='production' or (ENV["RAILS_ENV"]=='development' and Settings.devdb.adapter == 'oracle_enhanced')
      set_boolean_columns :uc_clc_is_su, :uc_clc_is_au, :uc_clc_is_vw, :uc_clc_active
    end

    before_save :set_default_values
    before_create :set_id

    def self.attributeDefaults
      {uc_clc_is_su:false, uc_clc_is_au:false, uc_clc_is_vw:false, uc_clc_active:false}
    end

    def self.get(uid)
      user_auth = uid.nil? ? nil : User::Auth.where(:uid => uid.to_s).first
      if user_auth.blank?
        # user's anonymous, or is not in the user_auth table, so give them an active status with zero permissions.
        user_auth = User::Auth.new(uid: uid, is_superuser: false, is_author: false, is_viewer: false, active: true)
      end
      user_auth
    end

    def self.new_or_update_superuser!(uid)
      use_pooled_connection {
        Retriable.retriable(:on => ActiveRecord::RecordNotUnique, :tries => 5) do
          user = self.where(uid: uid).first_or_initialize
          #super-user and test-user flags should probably be mutually exclusive...
          user.is_superuser = true
          user.active = true
          user.save
        end
      }
    end

  end
end
