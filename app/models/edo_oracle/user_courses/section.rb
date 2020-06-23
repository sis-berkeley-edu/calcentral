module EdoOracle
  module UserCourses
    class Section
      attr_reader :user

      delegate :uid, to: :user

      attr_accessor :term_id,
        :section_id,
        :instruction_format,
        :primary,
        :section_num,
        :start_date,
        :end_date,
        :session_id,
        :primary_associated_section_id,
        :enroll_status,
        :topic_description,
        :acad_career,
        :units_taken_law,
        :rqmnt_desg_descr,
        :waitlist_position,
        :waitlist_limit,
        :enroll_limit,
        :drop_class_if_enrl,
        :last_enrl_dt_stmp,
        :message_nbr,
        :error_message_txt,
        :uc_reason_desc,
        :uc_enrl_lastattmpt_date,
        :uc_enrl_lastattmpt_time,
        :rqmnt_designtn

      def initialize(user, row)
        @user = user

        @waitlist_info_present = row.include?('enroll_status')

        row.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def as_json(options={})
        base_json.merge(waitlist_json).merge(law_json)
      end

      def academic_career
        acad_career
      end

      def law?
        academic_career == 'LAW'
      end

      def course_catalog_number
        section_id&.to_s
      end

      def primary_section?
        to_boolean(primary)
      end

      def section_label
        "#{instruction_format} #{section_num}"
      end

      def section_number
        section_num
      end

      def waitlist_info_present?
        @waitlist_info_present
      end

      def waitlisted?
        enroll_status == 'W'
      end

      def requirements_designation_code
        rqmnt_designtn
      end

      def requirements_designation
        law_enrollment.fetch('rqmnt_desg_descr') { nil }
      end

      private

      def base_json
        {
          ccn: course_catalog_number,
          instruction_format: instruction_format,
          is_primary_section: primary_section?,
          section_label: section_label,
          section_number: section_number,
          topic_description: topic_description,
        }
      end

      def primary_section_json
        if primary_section?
          Hash.new.tap do |hash|
            hash[:start_date] = start_date if start_date
            hash[:end_date] = end_date if end_date
            hash[:session_id] = session_id if session_id
          end
        else
          { associated_primary_id: primary_associated_section_id }
        end
      end

      def waitlist_json
        if waitlist_info_present?
          if waitlisted?
            # Waitlist data relevant to students.
            {
              waitlisted: true,
              waitlistPosition: waitlist_position.to_i,
              enroll_limit: enroll_limit.to_i,
              drop_class_if_enrl: drop_class_if_enrl,
              last_enrl_dt_stmp: last_enrl_dt_stmp,
              message_nbr: message_nbr,
              error_message_txt: error_message_txt,
              uc_reason_desc: uc_reason_desc,
              uc_enrl_lastattmpt_date: uc_enrl_lastattmpt_date,
              uc_enrl_lastattmpt_time: uc_enrl_lastattmpt_time,
            }
          else
            {}
          end
        else
          # Enrollment and waitlist data relevant to instructors.
          {
            enroll_limit: enroll_limit.to_i,
            waitlist_limit: waitlist_limit.to_i,
          }
        end
      end

      def law_json
        return {} unless law?

        {
          lawUnits: units_taken_law,
          requirementsDesignation: requirements_designation,
        }
      end

      def law_enrollment
        return {} unless law?

        @law_enrollment ||= EdoOracle::Queries.get_law_enrollment(uid,
          academic_career,
          term_id,
          course_catalog_number,
          requirements_designation_code
        )
      end

      def to_boolean(string)
        string.try(:downcase) == 'true'
      end
    end
  end
end
