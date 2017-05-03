module StudentSuccess
  class TermGpa
    include MyAcademics::AcademicsModule

    def initialize(opts={})
      @student_uid_param = opts[:user_id]
      @active_careers = get_active_careers
    end

    def merge(data={})
      data[:termGpa] = get_term_gpas
    end

    def get_term_gpas
      response = CampusSolutions::StudentTermGpa.new(user_id: @student_uid_param).get
      parse_term_gpa response
    end

    def parse_term_gpa(response)
      if (term_gpas = response.try(:[], :feed).try(:[], :ucAaTermData).try(:[], :ucAaTermGpa))
        term_gpas.delete_if {|term| invalid_term_gpa? term}
        term_gpas.each do |term|
          term[:termName] = Berkeley::TermCodes.normalized_english term[:termName]
        end
        term_gpas
      end
    end

    def invalid_term_gpa?(term)
      term[:termId].to_i >= current_term.to_i || term[:termGpaUnits].to_i == 0 || !active_term_career?(term[:career])
    end

    def active_term_career?(career)
      @active_careers.include? career
    end

    def get_active_careers
      if (statuses = parse_hub_academic_statuses academic_status)
        parse_hub_careers statuses
      end
    end

    def academic_status
      @academic_status ||= HubEdos::MyAcademicStatus.new(@student_uid_param).get_feed
    end

    def current_term
      @current_term ||= Berkeley::Terms.fetch.current[:campus_solutions_id]
    end

  end
end
