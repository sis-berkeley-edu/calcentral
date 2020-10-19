module User
  class SavedUid < ApplicationRecord
    include ActiveRecordHelper, OraclePrimaryHelper

    self.table_name = 'PS_UC_SAVED_UIDS'
    self.primary_key = 'uc_clc_id'

    belongs_to :data, :class_name => 'User::Data', :foreign_key => 'uc_clc_oid'

    alias_attribute :stored_uid, :uc_clc_stor_id

    before_create :set_id

  end
end
