module StudentSuccess
  class TermGpa
    include Concerns::AcademicsModule

    def initialize(opts={})
      @student_uid_param = opts[:user_id]
      @active_careers = get_active_careers
    end

    def merge(data={})
      term_gpas = get_term_gpas
      data[:termGpaWithZero] = term_gpas.clone
      data[:termGpa] = remove_zero_gpas(term_gpas)
    end

    def remove_zero_gpas(term_gpas)
      term_gpas.delete_if {|term| term[:termGpaUnits].to_i == 0}
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
      term[:termId].to_i >= current_term.to_i || !active_term_career?(term[:career]) || term[:termEnrolled] != 'Y'
    end

    def active_term_career?(career)
      @active_careers.include? career
    end

    def get_active_careers
      if term_cpp = MyAcademics::MyTermCpp.new(@student_uid_param).get_feed
        current_cpp = term_cpp.select {|cpp| cpp.try(:[], 'term_id') >= current_term.to_s }
        return current_cpp.collect {|c| c.try(:[], 'acad_career_descr') }.uniq
      end
      []
    end

    def current_term
      @current_term ||= Berkeley::Terms.fetch.current[:campus_solutions_id]
    end

  end
end
