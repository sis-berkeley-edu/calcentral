module CampusSolutions
  module EnrollmentTermExpiry
    def self.expire(uid=nil)
      [
        EdoOracle::UserCourses::All,
        MyAcademics::Merged,
        MyAcademics::ClassEnrollments,
        MyRegistrations::Statuses
      ].each do |klass|
        klass.expire uid
      end
    end
  end
end
