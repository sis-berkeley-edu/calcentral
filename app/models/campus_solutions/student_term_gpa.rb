module CampusSolutions
  class StudentTermGpa < CachedProxy

    include StudentSuccessFeatureFlagged
    include CampusSolutionsIdRequired

    def url
      "#{@settings.base_url}/UC_AA_STDNT_GPA_TERMS.v1/get?EMPLID=#{@campus_solutions_id}"
    end

    def build_feed(response)
      # Since CS will always return a zero value for the current term, we want to suppress it
      current_term = Berkeley::Terms.fetch.current
      response.try(:[], 'UC_AA_TERM_DATA').try(:[], 'UC_AA_TERM_GPA').each do |term_gpa|
        if term_gpa.try(:[], 'TERM_ID') == current_term.try(:[], :campus_solutions_id)
          term_gpa['TERM_CUM_GPA'] = nil
        end
      end
      response.parsed_response
    end

    def xml_filename
      'student_term_gpa.xml'
    end
  end
end
