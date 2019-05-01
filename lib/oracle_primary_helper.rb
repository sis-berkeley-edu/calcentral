module OraclePrimaryHelper

  def set_id
    if ENV["RAILS_ENV"]=='production' or (ENV["RAILS_ENV"]=='development' and Settings.devdb.adapter == 'oracle_enhanced')
      self.uc_clc_id=self.class.find_by_sql("select #{self.class.table_name}_SEQ.nextval as uc_clc_id from dual").first.try(:uc_clc_id)
    end
  end

  def set_default_values
    self.class.attributeDefaults.each do |k, v|
      self[k]=v if self[k].blank?
    end
  end

end
