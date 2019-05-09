namespace :oec do

  desc 'Set up folder structure for new term'
  task :term_setup => :environment do
    opts = Oec::Task.opts_from_environment
    Oec::TermSetupTask.new(opts).run
  end

  desc 'Import per-department course CSVs, compare with dept spreadsheets and report on non-empty diffs'
  task :sis_import => :environment do
    opts = Oec::Task.opts_from_environment.merge(date_time: DateTime.now)
    Oec::SisImportTask.new(opts).run
  end

  desc 'Generate SIS data sheets, one per dept_code, to be shared with department admins'
  task :create_confirmation_sheets => :environment do
    opts = Oec::Task.opts_from_environment
    Oec::CreateConfirmationSheetsTask.new(opts).run
  end

  desc 'Compare department-managed sheets against latest SIS-import sheets'
  task :report_diff => :environment do
    opts = Oec::Task.opts_from_environment
    success = Oec::ReportDiffTask.new(opts).run
    unless success
      Rails.logger.error "#{Oec::ReportDiffTask.class} failed on #{opts}"
      break
    end
  end

  desc 'Merge sheets in \'departments\' folder to prepare for publishing'
  task :merge_confirmation_sheets => :environment do
    opts = Oec::Task.opts_from_environment
    Oec::MergeConfirmationSheetsTask.new(opts).run
  end

  desc 'Simply validate confirmation sheet data. This does not include a push to the \'exports\' directory.'
  task :validate_confirmation_sheets => :environment do
    opts = Oec::Task.opts_from_environment
    Oec::ValidationTask.new(opts).run
  end

  desc 'Push the most recently confirmed data to Explorance\'s Blue system'
  task :publish_to_explorance => :environment do
    opts = Oec::Task.opts_from_environment
    Oec::PublishTask.new(opts).run
  end

end
