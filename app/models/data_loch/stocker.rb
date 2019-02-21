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

    def get_daily_path()
      today = (Settings.terms.fake_now || DateTime.now).in_time_zone.strftime('%Y-%m-%d')
      digest = Digest::MD5.hexdigest today
      "daily/#{digest}-#{today}"
    end

    def upload_term_data(term_ids, s3_targets, is_historical=false)
      if is_historical
        data_type = 'historical'
        parent_path = 'historical'
      else
        data_type = 'daily'
        parent_path = get_daily_path
      end
      Rails.logger.warn "Starting #{data_type} course and enrollment data snapshot for term ids #{term_ids}, targets #{s3_targets}."
      Rails.logger.warn 'Disabling slow query logger for this task.'
      ActiveSupport::Notifications.unsubscribe 'sql.active_record'
      s3s = s3_from_names s3_targets
      term_ids.each do |term_id|
        Rails.logger.info "Starting snapshots for term #{term_id}."
        courses_path = DataLoch::Zipper.zip_query "courses-#{term_id}" do
          EdoOracle::Bulk.get_courses(term_id)
        end
        s3s.each {|s3| s3.upload("#{parent_path}/courses", courses_path) }
        enrollments_path = DataLoch::Zipper.zip_query_batched "enrollments-#{term_id}" do |batch, size|
          EdoOracle::Bulk.get_batch_enrollments(term_id, batch, size)
        end
        s3s.each {|s3| s3.upload("#{parent_path}/enrollments", enrollments_path) }
        clean_tmp_files([courses_path, enrollments_path])
        Rails.logger.info "Snapshots complete for term #{term_id}."
      end
    end

    def upload_advisee_data(s3_targets, jobs)
      # It seems safest to fetch the list of advisee SIDs from the same S3 environment which will receive their results,
      # but this could mean executing nearly the same large DB query multiple times in a row.
      # TODO Consider using the same SID list across environments.
      Rails.logger.warn "Starting #{jobs} data snapshot for targets #{s3_targets}."
      s3s = s3_from_names s3_targets
      previous_sids = nil
      job_paths = Hash[jobs.zip]
      s3s.each do |s3|
        sids = s3.load_advisee_sids()
        if sids != previous_sids
          jobs.each do |job|
            job_paths[job] = DataLoch::Zipper.zip_query job do
              case job
              when 'demographics'
                EdoOracle::Bulk.get_demographics sids
              when 'socio_econ'
                EdwOracle::Queries.get_socio_econ sids
              when 'applicant_scores'
                EdwOracle::Queries.get_applicant_scores sids
              else
                Rails.logger.error "Got unknown job name #{job}!"
              end
            end
          end
          previous_sids = sids
        end
        job_paths.each do |job, path|
          s3.upload("advisees/#{job}", path) if path
        end
      end
      clean_tmp_files(job_paths.values)
      Rails.logger.info "#{jobs} snapshots complete."
    end

    # Let tests intercept the file deletion.
    def clean_tmp_files(paths)
      paths.each {|p| FileUtils.rm p}
    end

  end
end
