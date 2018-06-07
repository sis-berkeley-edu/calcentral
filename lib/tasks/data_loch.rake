namespace :data_loch do

  desc 'Upload course and enrollment data snapshot to data loch S3 (TERM_ID = 2XXX,2XXX...)'
  task :snapshot => :environment do
    term_ids = ENV['TERM_ID']
    if term_ids.blank?
      Rails.logger.error 'Must specify TERM_ID as four-digit Campus Solutions id. Separate multiple term ids with commas.'
    else
      is_historical = ENV['HISTORICAL']
      data_type = is_historical ? 'historical' : 'daily'
      Rails.logger.warn "Starting #{data_type} course and enrollment data snapshot for term ids #{term_ids}."
      Rails.logger.warn 'Disabling slow query logger for this task.'
      ActiveSupport::Notifications.unsubscribe 'sql.active_record'

      s3 = DataLoch::S3.new

      term_ids.split(',').each do |term_id|
        Rails.logger.info "Starting snapshots for term #{term_id}."

        courses_path = DataLoch::Zipper.zip_courses term_id
        s3.upload('courses', courses_path, is_historical)
        FileUtils.rm courses_path

        enrollments_path = DataLoch::Zipper.zip_enrollments term_id
        s3.upload('enrollments', enrollments_path, is_historical)
        FileUtils.rm enrollments_path

        Rails.logger.info "Snapshots complete for term #{term_id}."
      end
    end
  end

end
