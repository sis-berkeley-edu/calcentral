# The UserAuth class is for record manipulation (the REST API for UserAuths),
# and allows for the API to be more clear without interfering with the internals
# of User::Auth, which is used internally for actually _doing_ authentication.
class UserAuth < ActiveRecord::Base
  include ActiveRecordHelper, OraclePrimaryHelper

  self.table_name = 'PS_UC_USER_AUTHS'
  self.primary_key = 'uc_clc_id'

  if self.primary_database_is_oracle?
    attribute :uc_clc_is_su, :boolean
    attribute :uc_clc_is_au, :boolean
    attribute :uc_clc_is_vw, :boolean
    attribute :uc_clc_active, :boolean
  end

  # Give better names to the Campus Solutions columns we're stuck with.
  alias_attribute :id, :uc_clc_id
  alias_attribute :uid, :uc_clc_ldap_uid
  alias_attribute :is_active, :uc_clc_active
  alias_attribute :is_viewer, :uc_clc_is_vw
  alias_attribute :is_superuser, :uc_clc_is_su
  alias_attribute :is_author, :uc_clc_is_au

  validates :uid, presence: true, uniqueness: true

  before_save :set_default_values
  before_create :set_id

  def as_json(options={})
    {
      id: id,
      uid: uid,
      is_active: is_active,
      is_author: is_author,
      is_superuser: is_superuser,
      is_viewer: is_viewer,
    }
  end

  private

  def set_default_values
    self.is_active = false unless is_active
    self.is_author = false unless is_active
    self.is_superuser = false unless is_active
    self.is_viewer = false unless is_active
  end
end
