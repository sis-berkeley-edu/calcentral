module DataLoch
  class Stocker

    def s3_from_names(targets)
      s3s = []
      if targets.blank?
        Rails.logger.warn 'Should specify names of S3 configurations. Defaulting to deprecated single-target configuration.'
        s3s << DataLoch::S3.new
      else
        targets.each do |target|
          s3s << DataLoch::S3.new(target)
        end
      end
      s3s
    end

    def upload_term_data(term_ids, s3_targets, is_historical=false)
      data_type = is_historical ? 'historical' : 'daily'
      Rails.logger.warn "Starting #{data_type} course and enrollment data snapshot for term ids #{term_ids}, targets #{s3_targets}."
      Rails.logger.warn 'Disabling slow query logger for this task.'
      ActiveSupport::Notifications.unsubscribe 'sql.active_record'
      s3s = s3_from_names s3_targets

      term_ids.each do |term_id|
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

    def upload_advisee_demographics(s3_targets)
      # It seems safest to fetch the list of advisee SIDs from the same S3 environment which will receive their results,
      # but this could mean executing nearly the same large DB query multiple times in a row.
      # TODO Consider using the same SID list across environments.
      Rails.logger.warn "Starting demographics data snapshot for targets #{s3_targets}."
      s3s = s3_from_names s3_targets
      previous_sids = nil
      demographics_path = nil
      s3s.each do |s3|
        sids = s3.load_advisee_sids()
        if sids != previous_sids
          demographics_path = DataLoch::Zipper.zip_demographics(sids)
          previous_sids = sids
        end
        s3.upload('demographics', demographics_path)
        Rails.logger.info "Demographics snapshot complete."
      end
    end

  end
end
