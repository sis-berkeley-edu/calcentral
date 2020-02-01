module User
  module BCourses
    class Course
      attr_accessor :id, :name, :account_id, :uuid, :start_at,
        :grading_standard_id, :is_public, :created_at, :course_code,
        :default_view, :root_account_id, :enrollment_term_id, :license,
        :grade_passback_setting, :end_at, :public_syllabus,
        :public_syllabus_to_auth, :storage_quota_mb, :is_public_to_auth_users,
        :term, :apply_assignment_group_weights, :calendar, :time_zone,
        :blueprint, :sis_course_id, :sis_import_id, :integration_id,
        :enrollments, :hide_final_grades, :workflow_state,
        :restrict_enrollments_to_course_dates, :overridden_course_visibility

      def initialize(attrs={})
        attrs.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end
    end
  end
end
