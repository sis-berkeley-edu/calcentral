module User
  class RecentUid < ApplicationRecord
    include ActiveRecordHelper, OraclePrimaryHelper

    MAX_PER_OWNER_ID = 30

    self.table_name = 'PS_UC_RECENT_UIDS'
    self.primary_key = 'uc_clc_id'

    belongs_to :data, :class_name => 'User::Data', :foreign_key => 'uc_clc_oid'

    alias_attribute :stored_uid, :uc_clc_stor_id
    alias_attribute :owner_id, :uc_clc_oid

    before_create :limit_by_owner_id

    def limit_by_owner_id
      record_ids = self.class.where(uc_clc_oid: self.uc_clc_oid.to_s).order(:created_at).pluck(:uc_clc_id)
      if record_ids.count >= MAX_PER_OWNER_ID
        self.class.delete record_ids.slice(0..-MAX_PER_OWNER_ID)
      end
      set_id
    end

  end
end
