module StudentSuccess
  class TermGpa

    def initialize(opts={})
      @student_uid_param = opts[:user_id]
    end

    def merge(data={})
      data[:termGpa] = term_gpa
    end

    def term_gpa
      response = CampusSolutions::StudentTermGpa.new(user_id: @student_uid_param).get
      parse_term_gpa response
    end

    def parse_term_gpa(response)
      current_term = Berkeley::Terms.fetch.current[:campus_solutions_id]
      term_gpa = response.try(:[], :feed).try(:[], :ucAaTermData).try(:[], :ucAaTermGpa)
      if term_gpa.present?
        term_gpa.each do |term_obj|
          if term_obj[:termId].to_i >= current_term.to_i || term_obj[:termGpaUnits].to_i == 0
            term_obj[:termGpa] = nil
          end
          term_obj[:termName] = Berkeley::TermCodes.normalized_english term_obj[:termName]
        end
        term_gpa
      end
    end

  end
end
