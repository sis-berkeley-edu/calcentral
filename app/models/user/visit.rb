module User
  class Visit < ApplicationRecord
    extend Cache::Cacheable
    include ActiveRecordHelper

    self.table_name = 'user_visits'

    after_initialize :log_access
    attr_accessible :uid, :last_visit_at

    def self.expire(id = nil)
      # no-op; we want to just expire with time, not when the cache is forcibly cleared.
    end

    def record_timestamps
      false
    end

    self.primary_key = :uid

    def self.record(uid)
      fetch_from_cache uid  do
        use_pooled_connection {
          Retriable.retriable(:on => ActiveRecord::RecordNotUnique, :tries => 5) do
            visit = self.where(uid: uid).first_or_initialize
            visit.last_visit_at = DateTime.now
            visit.save
          end
        }
      end
    end
  end
end
