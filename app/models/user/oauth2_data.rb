module User
  class Oauth2Data < ActiveRecord::Base
    include ActiveRecordHelper, SafeJsonParser, OraclePrimaryHelper

    self.table_name = 'PS_UC_CLC_OAUTH'
    self.primary_key = 'uc_clc_id'

    after_initialize :log_access, :log_threads

    attr_accessible :uid, :app_id, :access_token, :expiration_time, :refresh_token, :app_data

    serialize :access_token
    serialize :refresh_token
    serialize :app_data, Hash
    before_create :set_id
    before_save :set_default_values, :encrypt_tokens
    after_save :decrypt_tokens, :expire_user
    after_destroy :expire_user
    after_find :decrypt_tokens
    @@encryption_algorithm = Settings.oauth2.encryption
    @@encryption_key = Settings.oauth2.key

    alias_attribute :uid, :uc_clc_ldap_uid

    def self.attributeDefaults
      {refresh_token:'', app_data:{'clc_null' => true}, expiration_time:0}
    end

    def self.get(user_id)
      hash = {}
      use_pooled_connection {
        oauth2_data = self.where(uid: user_id).first

        if oauth2_data
          oauth2_data.attributes.each { |key, value| hash[key] = value }
        end
      }
      hash.symbolize_keys
    end

    def self.remove(uid)
      use_pooled_connection {
        self.destroy_all(uid: uid)
      }
      Cache::UserCacheExpiry.notify uid
    end

    def self.get_google_email(user_id)
      get_appdata_field(user_id, 'email')
    end

    def self.is_google_reminder_dismissed(user_id)
      get_appdata_field(user_id, 'is_reminder_dismissed')
    end

    def self.update_google_email!(user_id)
      #will be a noop if user hasn't granted google access
      use_pooled_connection {
        authenticated_entry = self.where(uid: user_id).first
        return unless authenticated_entry
        userinfo = GoogleApps::Userinfo.new(user_id: user_id).user_info
        return unless userinfo && userinfo.response.status == 200 && userinfo.data["emailAddresses"].present? && userinfo.data["emailAddresses"].length > 0
        authenticated_entry.app_data_will_change!
        authenticated_entry.app_data["email"] = userinfo.data["emailAddresses"].first["value"]
        authenticated_entry.save
      }
    end

    def self.new_or_update(user_id, access_token, refresh_token=nil, expiration_time=nil, options={})
      use_pooled_connection {
        Retriable.retriable(:on => ActiveRecord::RecordNotUnique, :tries => 5) do
          entry = self.where(:uid => user_id).first_or_initialize
          entry.access_token = access_token
          entry.refresh_token = refresh_token
          entry.expiration_time = expiration_time
          if !options.blank?
            if !options[:app_data].blank? && options[:app_data].is_a?(Hash)
              entry.app_data ||= {}
              new_app_data = entry.app_data.merge options[:app_data]
              entry.app_data = new_app_data
            else
              Rails.logger.warn "#{self.class.name}: User::Oauth2Data:app_data not saved (either blank? or not a hash): #{options[:app_data]}"
            end
          end
          entry.app_data.delete_if { |key, value| key == 'is_reminder_dismissed' } if entry.access_token.present?
          entry.save
        end
      }
    end

    def self.dismiss_google_reminder(user_id)
      new_or_update(user_id, '', '', 0, {
        app_data: {'is_reminder_dismissed' => true}
      })
    end

    def encrypt_tokens
      self.access_token = self.class.encrypt_with_iv(self.access_token)
      self.refresh_token = self.class.encrypt_with_iv(self.refresh_token) if self.refresh_token
    end

    def decrypt_tokens
      if self.has_attribute?(:access_token)
        self.access_token = self.class.decrypt_with_iv(self.access_token)
        self.refresh_token = self.class.decrypt_with_iv(self.refresh_token) if self.refresh_token
      end
    end

    def expire_user
      Cache::UserCacheExpiry.notify @uid
    end

    def self.encrypt_with_iv(value)
      return value if value.blank?
      cipher = OpenSSL::Cipher.new(@@encryption_algorithm)
      cipher.encrypt
      iv = cipher.random_iv
      cipher.key = @@encryption_key
      cipher.iv = iv
      encrypted = cipher.update(value) + cipher.final
      [Base64.encode64(encrypted), Base64.encode64(iv)]
    end

    def self.decrypt_with_iv(value_with_iv)
      return value_with_iv if value_with_iv.blank?
      cipher = OpenSSL::Cipher.new(@@encryption_algorithm)
      cipher.decrypt
      cipher.key = @@encryption_key
      cipher.iv = Base64.decode64(value_with_iv[1])
      decrypted = cipher.update(Base64.decode64(value_with_iv[0])) + cipher.final
      decrypted.to_s
    end

    private

    def self.get_appdata_field(uid, field)
      oauth2_data = false
      use_pooled_connection {
        oauth2_data = self.where(uid: uid).first
      }
      if oauth2_data && oauth2_data.app_data && oauth2_data.app_data[field]
        oauth2_data.app_data[field]
      else
        ''
      end
    end

  end
end
