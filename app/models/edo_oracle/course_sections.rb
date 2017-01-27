module EdoOracle
  class CourseSections < BaseProxy
    include ClassLogger

    def initialize(term_id, section_id)
      super(Settings.edodb)
      @term_id = term_id
      @section_id = section_id
    end

    def get_section_data
      self.class.fetch_from_cache "#{@section_id}-#{@term_id}" do
        {
          instructors: get_section_instructors,
          schedules: get_section_schedules,
          final_exams: get_section_final_exam
        }
      end
    end

    private

    def get_section_schedules
      schedules = {
        oneTime: [],
        recurring: []
      }
      EdoOracle::Queries.get_section_meetings(@term_id, @section_id).each do |meeting|
        if meeting && meeting['meeting_days'].present? && (location = translate_location meeting)
          if meeting['meeting_start_date'] == meeting['meeting_end_date']
            schedules[:oneTime] << location.merge(one_time_session meeting)
          else
            schedules[:recurring] << location.merge(recurring_schedule meeting)
          end
        end
      end
      schedules
    end

    def get_section_final_exam
      final_exams = EdoOracle::Queries.get_section_final_exam(@term_id, @section_id).map do |exam|
        {
          exam_type: exam['exam_type'],
          location: exam['location'],
          exam_date: exam['exam_date'],
          exam_start_time: exam['exam_start_time'],
          exam_end_time: exam['exam_end_time']
        }
      end
      final_exams.uniq
    end

    def get_section_instructors
      instructors = EdoOracle::Queries.get_section_instructors(@term_id, @section_id).map do |instructor|
        {
          name: instructor['person_name'],
          role: instructor['role_code'],
          gradeRosterAccess: instructor['grade_roster_access'],
          uid: instructor['ldap_uid'],
          printInSchedule: instructor['print_in_schedule']
        }
      end
      instructors.uniq
    end

    def strip_leading_zeros(str=nil)
      (str.nil?) ? nil : "#{str}".gsub!(/^[0]*/, '')
    end

    def translate_location(meeting)
      return {} if meeting['location'].blank?
      if meeting['location'] == 'Requested General Assignment'
        building_name = 'Room not yet assigned'
      else
        # See spec for behavior of this regex.
        if (partitioned = meeting['location'].match /\A(.*)\s+(\w*\d[^\s]*)\Z/)
          building_name, room_number = partitioned[1].to_s, partitioned[2].to_s
        else
          building_name = meeting['location']
        end
      end
      {
        buildingName: building_name,
        roomNumber: strip_leading_zeros(room_number)
      }
    end

    def one_time_session(meeting)
      date = [
        translate_meeting_days(meeting['meeting_days']),
        meeting['meeting_start_date'].strftime('%-m/%d')
      ].join(' ')
      {
        date: date,
        time: translate_meeting_time(meeting)
      }
    end

    def recurring_schedule(meeting)
      schedule = [
        translate_meeting_days(meeting['meeting_days']),
        translate_meeting_time(meeting)
      ].join(' ')
      {
        schedule: schedule
      }
    end

    def translate_meeting_days(days)
      translated = ''
      if days.present?
        days.chars.each_slice(2).inject(translated) do |translated, day_chars|
          translated << case day_chars.join
                          when 'SU' then 'Su'
                          when 'MO' then 'M'
                          when 'TU' then 'Tu'
                          when 'WE' then 'W'
                          when 'TH' then 'Th'
                          when 'FR' then 'F'
                          when 'SA' then 'Sa'
                          else ''
                        end
        end
      end
      translated
    end

    def translate_meeting_time(meeting)
      if meeting['meeting_start_time'].present?
        translated = translate_time meeting['meeting_start_time']
        translated << "-#{translate_time meeting['meeting_end_time']}" unless meeting['meeting_end_time'].blank?
      end
      translated
    end

    def translate_time(time)
      # 9:00A, 11:30A, 3:14P
      Time.parse(time).strftime('%-l:%M%p').sub(/M\Z/, '')
    rescue ArgumentError
      logger.error "Bad time value for course #{@section_id}, term #{@term_id}: #{time}"
      ''
    end

  end
end
