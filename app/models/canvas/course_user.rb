module Canvas
  class CourseUser < Proxy
    include ClassLogger

    ADMIN_ROLES = ['TeacherEnrollment', 'TaEnrollment', 'DesignerEnrollment',
      'Owner', 'Maintainer', 'Lead TA']

    def initialize(options = {})
      super(options)
      raise ArgumentError, 'User ID option required' unless options.has_key?(:user_id)
      raise ArgumentError, 'User ID option must be a Fixnum' if options[:user_id].class != Fixnum
      raise ArgumentError, 'Course ID option required' unless options.has_key?(:course_id)
      raise ArgumentError, 'Course ID option must be a Fixnum' if options[:course_id].class != Fixnum
      @user_id = options[:user_id]
      @course_id = options[:course_id]
    end

    def course_user(options = {})
      response = optional_cache(options, key: "#{@course_id}/#{@user_id}", default: true) { user_response }
      if response[:statusCode] < 400
        feed = response[:body]
        if feed['enrollments']
          # CLC-6803 : An Instructure bug may have injected enrollments from other site memberships into this response.
          # If so, weed them out.
          fixed_enrollments = feed['enrollments'].select { |enr| enr['course_id'] == @course_id }
          if fixed_enrollments.length <  feed['enrollments'].length
            logger.warn("Extraneous enrollments found in Canvas Course User API for course #{@course_id}, user #{@user_id}")
            feed['enrollments'] = fixed_enrollments
          end
        end
        return feed
      end
    end

    def self.is_course_admin?(canvas_course_user)
      return false if canvas_course_user.blank?
      canvas_course_user['enrollments'].each do |enrollment|
        return true if ADMIN_ROLES.include?(enrollment['role'])
      end
      false
    end

    def self.is_course_teacher?(canvas_course_user)
      return false if canvas_course_user.blank?
      canvas_course_user['enrollments'].each do |enrollment|
        return true if enrollment['role'] == 'TeacherEnrollment'
      end
      false
    end

    def self.is_course_lead_ta?(canvas_course_user)
      return false if canvas_course_user.blank?
      canvas_course_user['enrollments'].each do |enrollment|
        return true if enrollment['role'] == 'Lead TA'
      end
      false
    end

    def self.is_course_teachers_assistant?(canvas_course_user)
      return false if canvas_course_user.blank?
      canvas_course_user['enrollments'].each do |enrollment|
        return true if ['TaEnrollment', 'Lead TA'].include? enrollment['role']
      end
      false
    end

    def self.is_course_reader?(canvas_course_user)
      return false if canvas_course_user.blank?
      canvas_course_user['enrollments'].each do |enrollment|
        return true if enrollment['role'] == 'Reader'
      end
      false
    end

    def self.has_instructing_role?(canvas_course_user)
      is_course_teacher?(canvas_course_user) || is_course_teachers_assistant?(canvas_course_user) || is_course_reader?(canvas_course_user)
    end

    def user_response
      wrapped_get request_path
    end

    # Do not need to log a stack trace when the user is not a course site member.
    def existence_check
      true
    end

    private

    # Interface to request a single user in a course
    # See https://canvas.instructure.com/doc/api/courses.html#method.courses.user
    def request_path
      "courses/#{@course_id}/users/#{@user_id}?include[]=enrollments"
    end

    def mock_json
      read_file('fixtures', 'json', 'canvas_course_user.json')
    end
  end
end
