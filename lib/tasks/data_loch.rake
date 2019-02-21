namespace :data_loch do

  desc 'Upload course, enrollment, and advisee data snapshots to data loch S3 (TERM_ID = 2XXX,2XXX...)'
  task :snapshot => :environment do
    term_ids = ENV['TERM_ID']
    advisee_data = []
    advisee_data << 'demographics' if ENV['DEMOGRAPHICS']
    advisee_data.concat ['socio_econ', 'applicant_scores'] if ENV['EDW']
    if term_ids.blank? && advisee_data.blank?
      Rails.logger.error 'Neither TERM_ID, DEMOGRAPHICS, nor EDW is specified. Nothing to upload.'
    end
    if term_ids.present?
      term_ids = term_ids.split(',')
    end
    targets = ENV['TARGETS']
    if targets.blank?
      Rails.logger.warn 'Should specify TARGETS as names of S3 configurations. Separate multiple target names with commas.'
      targets = nil
    else
      targets = targets.split(',')
    end
    is_historical = ENV['HISTORICAL']
    stocker = DataLoch::Stocker.new()
    if term_ids.present?
      stocker.upload_term_data(term_ids, targets, is_historical)
    end
    if advisee_data.present?
      stocker.upload_advisee_data(targets, advisee_data)
    end
  end

end
