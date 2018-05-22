module EdoOracle
  class Student < BaseProxy
    include ClassLogger

    def initialize(options = {})
      super(Settings.edodb, options)
    end

    def concurrent?
      cs_id = User::Identifiers.lookup_campus_solutions_id @uid
      status = EdoOracle::Queries.get_concurrent_student_status cs_id
      status.try(:[], 'concurrent_status') == 'Y'
    end
  end
end
