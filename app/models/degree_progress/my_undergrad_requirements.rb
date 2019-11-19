module DegreeProgress
  class MyUndergradRequirements < UserSpecificModel
    # This model provides an student-specific version of milestone data for UGRD career.
    # TODO Could be replaced by adding FilterJsonOutput to a shared cached feed.
    include Cache::CachedFeed
    include Cache::JsonifiedFeed
    include Cache::UserCacheExpiry
    include RequirementsModule

    LINK_ID = 'UC_CX_APR_RPT_FOR_STDNT'

    def get_feed_internal
      return {} unless is_feature_enabled?
      response = CampusSolutions::DegreeProgress::UndergradRequirements.new(user_id: @uid).get
      if response[:errored] || response[:noStudentId]
        response[:feed] = {}
      else
        response[:feed] = {
          degree_progress: process(response)
        }
        add_links response
      end
      HashConverter.camelize response
    end

    def add_links(response)
      if should_see_links?
        response[:feed][:links] = get_links
      end
    end

    def get_incomplete_programs_roles
      ugrd_statuses = MyAcademics::MyAcademicStatus.statuses_by_career_role(@uid, ['ugrd'])
      return [] if ugrd_statuses.blank?

      plans = incomplete_plans_from_statuses(ugrd_statuses)
      return [] if plans.blank?

      plans.map do |plan|
        program = plan.try(:[], 'academicPlan').try(:[], 'academicProgram').try(:[], 'program')
        program.try(:[], 'code')
      end.uniq.compact
    end

    def should_see_links?
      incomplete_programs_roles = get_incomplete_programs_roles
      authorized_program_roles = [
        'UCLS',
        'UCOE',
        'UCED',
        'UBUS',
      ]
      if ucnr_apr_link_enabled?
        authorized_program_roles << 'UCNR'
      end
      !(authorized_program_roles & incomplete_programs_roles).empty?
    end

    def is_feature_enabled?
      Settings.features.cs_degree_progress_ugrd_student
    end

    def ucnr_apr_link_enabled?
      Settings.features.cs_degree_progress_ugrd_ucnr_apr_link
    end

    def incomplete_plans_from_statuses(statuses)
      [].tap do |plans|
        statuses.try(:each) do |status|
          status.try(:[], 'studentPlans').try(:each) do |plan|
            if incomplete_plan? plan
              plans.push(plan)
            end
          end
        end
      end
    end

    def incomplete_plan?(plan)
      plan.try(:[], 'statusInPlan').try(:[], 'status').try(:[], 'code') != 'CM'
    end
  end
end
