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

    def should_see_links?
      roles = MyAcademics::MyAcademicRoles.new(@uid).get_feed
      authorized_program_roles = [
        'lettersAndScience',
        'ugrdEngineering',
        'ugrdEnvironmentalDesign',
        'ugrdHaasBusiness',
      ]
      !!authorized_program_roles.find {|role_string| roles[:current][role_string] }
    end

    def is_feature_enabled?
      Settings.features.cs_degree_progress_ugrd_student
    end
  end
end
