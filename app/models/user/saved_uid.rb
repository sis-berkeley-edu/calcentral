module User
  class SavedUid < ActiveRecord::Base
    include ActiveRecordHelper, OraclePrimaryHelper

    self.table_name = 'PS_UC_SAVED_UIDS'
    self.primary_key = 'uc_clc_id'

    belongs_to :data, :class_name => 'User::Data', :foreign_key => 'uc_clc_oid'

    attr_accessible :uc_clc_stor_id, :uc_clc_id, :created_at, :updated_at
    alias_attribute :stored_uid, :uc_clc_stor_id

    before_create :set_id

  end
end
