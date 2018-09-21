module CanvasLti
  class ProjectProvision
    include ClassLogger, SafeJsonParser
    extend Cache::Cacheable

    def initialize(uid)
      @uid = uid
    end

    def unique_sis_project_id
      15.times do
        sis_course_id = 'PROJ:' + SecureRandom.hex(8)
        logger.debug "Checking SIS ID #{sis_course_id} for uniqueness"
        existing_course_for_id = Canvas::SisCourse.new(user_id: @uid, sis_course_id: sis_course_id).course
        return sis_course_id unless existing_course_for_id[:statusCode] == 200
      end
      raise RuntimeError, 'Unable to find unique SIS Course ID for Project Site'
    end

    def create_project(project_name)
      project_account_id = Settings.canvas_proxy.projects_account_id
      term_id = Settings.canvas_proxy.projects_term_id
      template_id = Settings.canvas_proxy.projects_template_id
      worker = Canvas::Course.new(user_id: @uid)
      response = worker.create(project_account_id, project_name, project_name, term_id, unique_sis_project_id)
      if (course_details = response[:body])
        site_id = course_details['id']
        response = Canvas::CourseCopyImport.new(canvas_course_id: site_id).import_course_template(template_id)
        if (import_status = response[:body]) && import_status['workflow_state'] != 'completed'
          progress_id = import_status['progress_url'].split('/').last
          import_start_time = Time.now.to_i
        end

        enrollment = CanvasLti::CourseAddUser.new(user_id: @uid, canvas_course_id: course_details['id']).add_user_to_course(@uid, 'Owner')

        if progress_id
          import_state = 'new'
          15.times do
            response = Canvas::Progress.new(progress_id: progress_id).get_progress
            import_state = response[:body] && response[:body]['workflow_state']
            break if !import_state || import_state == 'completed'
            sleep 1
          end
          elapsed_time = Time.now.to_i - import_start_time
          if import_state == 'completed'
            logger.warn("Project site #{site_id} template import completed after #{elapsed_time} seconds")
          else
            logger.warn("Project site #{site_id} template import not completed after #{elapsed_time} seconds")
          end
        end

        return {
          projectSiteId: site_id,
          projectSiteUrl: "#{Settings.canvas_proxy.url_root}/courses/#{site_id}",
          enrollment_id: enrollment['id']
        }
      else
        raise Errors::ProxyError.new("Project Site creation request failed: #{response[:statusCode]} #{response[:body]}")
      end
    end
  end
end
