namespace :data_loch do

  desc 'Upload course and enrollment data snapshot to data loch S3 (TERM_ID = 2XXX,2XXX...)'
  task :snapshot => :environment do
    term_ids = ENV['TERM_ID']
    if term_ids.blank?
      Rails.logger.error 'Must specify TERM_ID as four-digit Campus Solutions id. Separate multiple term ids with commas.'
    else
      s3s = []
      targets = ENV['TARGETS']
      if targets.blank?
        Rails.logger.warn 'Should specify TARGETS as names of S3 configurations. Separate multiple target names with commas.'
        Rails.logger.warn 'Defaulting to deprecated single-target configuration.'
        s3s << DataLoch::S3.new
      else
        targets.split(',').each do |target|
          s3s << DataLoch::S3.new(target)
        end
      end

      is_historical = ENV['HISTORICAL']
      data_type = is_historical ? 'historical' : 'daily'
      Rails.logger.warn "Starting #{data_type} course and enrollment data snapshot for term ids #{term_ids}."
      Rails.logger.warn 'Disabling slow query logger for this task.'
      ActiveSupport::Notifications.unsubscribe 'sql.active_record'

      term_ids.split(',').each do |term_id|
        Rails.logger.info "Starting snapshots for term #{term_id}."

        courses_path = DataLoch::Zipper.zip_courses term_id
        s3s.each {|s3| s3.upload('courses', courses_path, is_historical) }
        FileUtils.rm courses_path

        enrollments_path = DataLoch::Zipper.zip_enrollments term_id
        s3s.each {|s3| s3.upload('enrollments', enrollments_path, is_historical) }
        FileUtils.rm enrollments_path

        Rails.logger.info "Snapshots complete for term #{term_id}."
      end
    end
  end

end
