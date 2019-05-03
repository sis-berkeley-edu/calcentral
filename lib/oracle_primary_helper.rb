module OraclePrimaryHelper

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def primary_database_is_oracle?
      ActiveRecord::Base.connection.class.name == 'ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter'
    end
  end

  def set_id
    if self.class.primary_database_is_oracle?
      self.uc_clc_id=self.class.find_by_sql("select #{self.class.table_name}_SEQ.nextval as uc_clc_id from dual").first.try(:uc_clc_id)
    end
  end

  def set_default_values
    self.class.attributeDefaults.each do |k, v|
      self[k]=v if self[k].blank?
    end
  end

end
