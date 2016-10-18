module CampusSolutions
  module DegreeProgress
    class GraduateMilestones < Proxy

      include CampusSolutionsIdRequired

      def initialize(options = {})
        super options
        initialize_mocks if @fake
      end

      def xml_filename
        'degree_progress_graduate.xml'
      end

      def url
        "#{@settings.base_url}/UC_AA_PROGRESS_GET.v1/UC_AA_PROGRESS_GET?EMPLID=#{@campus_solutions_id}"
      end
    end
  end
end
