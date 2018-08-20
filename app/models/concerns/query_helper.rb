module Concerns
  module QueryHelper

    UC_BERKELEY = 'UCB01'

    def self.included(target)
      target.extend ClassMethods
    end

    module ClassMethods

      def and_institution(object_alias)
        <<-SQL
          AND #{object_alias}.INSTITUTION = '#{UC_BERKELEY}'
        SQL
      end
    end

  end
end
