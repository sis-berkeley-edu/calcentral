module Oec
  module Administrator
    include ClassLogger

    def self.is_admin?(uid)
      administrator_uid = Settings.oec.administrator_uid
      if (invalid_config = administrator_uid.blank?)
        logger.error 'OEC admin cannot log in because our YAML has blank \'oec.administrator_uid\' config.'
      end
      !invalid_config && uid.to_s == administrator_uid
    end

  end
end
