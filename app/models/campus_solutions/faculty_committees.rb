module CampusSolutions
  class FacultyCommittees < Proxy

    include CommitteesFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def xml_filename
      'faculty_committees.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      "#{@settings.base_url}/UC_SR_FACULTY_COMMITTEE.v1/UC_SR_FACULTY_COMMITTEE_GET?EMPLID=#{@campus_solutions_id}"
    end

  end
end
