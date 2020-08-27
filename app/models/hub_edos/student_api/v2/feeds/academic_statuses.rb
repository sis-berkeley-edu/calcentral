module HubEdos
  module StudentApi
    module V2
      module Feeds
        class AcademicStatuses < ::HubEdos::StudentApi::V2::Feeds::Proxy
          include HubEdos::CachedProxy
          include Cache::UserCacheExpiry

          attr_reader :include_inactive_programs, :include_completed_programs

          def initialize(options={})
            super(options)
            options.reverse_merge!({
              include_completed_programs: false,
              include_inactive_programs: false,
            })
            @include_inactive_programs = !!options[:include_inactive_programs]
            @include_completed_programs = !!options[:include_completed_programs]
          end

          def get_active_only
            @include_inactive_programs = false
            @include_completed_programs = false
            get
          end

          def get_inactive_completed
            @include_inactive_programs = true
            @include_completed_programs = true
            get
          end

          def url()
            "#{@settings.base_url}/v2/students/#{@campus_solutions_id}?inc-acad=true&inc-inactive-programs=#{include_inactive_programs}&inc-completed-programs=#{include_completed_programs}"
          end

          def json_filename
            'hub_v2_student_academic_status.json'
          end

          def whitelist_fields
            ['academicStatuses', 'holds', 'awardHonors', 'degrees']
          end
        end
      end
    end
  end
end
