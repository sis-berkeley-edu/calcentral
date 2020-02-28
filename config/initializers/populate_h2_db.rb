# This code will always run on boot EXCEPT when the ENV variable SKIP_DB is set
# (to anything).
#
# Take advantage of this to avoid loading the database when you absolutely
# don't need it. For instance:
#
# SKIP_DB=true bundle exec rspec spec/models/user/b_courses/activity_spec.rb
unless ENV.fetch('SKIP_DB') { false }
  def seed_data(file_name)
    file_path = Rails.root.join("db", "seeds", file_name)

    string = ""
    file = File.open(file_path,  "r")
    file.each_line do |line|
      string += line
    end
    string
  end

  class PopulateCampusH2 < ActiveRecord::Base
    Rails.application.config.after_initialize do
      if Settings.campusdb.adapter == "h2" && Rails.env.test?
        establish_connection :campusdb
        sql = seed_data('campus_h2.sql')
        connection.execute sql

        # Insert binary data for the test student photo.
        raw_data = File.open(Rails.root.join('public', 'dummy', 'images', 'sample_student_72x96.jpg'), 'rb').read
        sql = "insert into CALCENTRAL_STUDENT_PHOTO_VW (student_ldap_uid, bytes, photo) values (300939, #{raw_data.length}, '#{raw_data.unpack('H*').first}');"
        connection.execute(sql)
      end
    end
  end

  class PopulateSisedosH2 < ActiveRecord::Base
    include ClassLogger
    Rails.application.config.after_initialize do
      logger.warn('Initializing SISEDO')
      if Settings.edodb.adapter == 'h2'
        logger.warn('Connecting to SISEDO')
        establish_connection :edodb
        sql = seed_data('sisedo_h2.sql')

        connection.execute sql
      end
    end
  end

  class PopulateSysadmH2 < ActiveRecord::Base
    include ClassLogger
    Rails.application.config.after_initialize do
      logger.warn("Initializing SYSADM")
      if Settings.edodb.adapter == "h2"
        logger.warn("Connecting to SYSADM")
        establish_connection :edodb

        sql = seed_data('sysadm_h2.sql')
        connection.execute sql
      end
    end
  end
end
