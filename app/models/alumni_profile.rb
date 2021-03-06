class AlumniProfile < ActiveRecord::Base
  include OraclePrimaryHelper

  self.table_name = 'PS_UC_CC_AF_NOLNCH'
  self.primary_key = 'oprid'

  alias_attribute :uid, :oprid
  alias_attribute :updated_at, :lastupddttm
  
  validates :uid, presence: true
  
  before_save :set_default_values

  def self.attributeDefaults
      { lastupddttm:Time.zone.today.in_time_zone.to_datetime}
  end

end