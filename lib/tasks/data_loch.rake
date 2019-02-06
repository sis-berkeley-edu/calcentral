namespace :data_loch do

  desc 'Upload course and enrollment data snapshot to data loch S3 (TERM_ID = 2XXX,2XXX...)'
  task :snapshot => :environment do
    term_ids = ENV['TERM_ID']
    include_demographics = ENV['DEMOGRAPHICS']
    if term_ids.blank? && !include_demographics
      Rails.logger.error 'Neither TERM_ID nor DEMOGRAPHICS is specified. Nothing to upload.'
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
    if include_demographics
      stocker.upload_advisee_demographics targets
    end
  end

end
