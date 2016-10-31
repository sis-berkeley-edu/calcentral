module CampusSolutions
  class StudentTermGpa < CachedProxy

    include StudentSuccessFeatureFlagged
    include CampusSolutionsIdRequired

    def url
      "#{@settings.base_url}/UC_AA_STDNT_GPA_TERMS.v1/get?EMPLID=#{@campus_solutions_id}"
    end

    def xml_filename
      'student_term_gpa.xml'
    end
  end
end
