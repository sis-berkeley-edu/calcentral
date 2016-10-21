module CampusSolutions
  class Grading < CachedProxy

    include CampusSolutionsIdRequired

    def url
      "#{@settings.base_url}/UC_SR_FACULTY_GRADING.v1/Get?EMPLID=#{@campus_solutions_id}"
    end

    def xml_filename
      'grading.xml'
    end
  end
end
