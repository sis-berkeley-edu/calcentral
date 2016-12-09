module CampusSolutions
  module SectionGradesExpiry
    def self.expire(uids=[])
      uids.each do |uid|
        [MyAcademics::Merged, CampusSolutions::Grading].each do |klass|
          klass.expire uid
        end
      end
    end
  end
end
