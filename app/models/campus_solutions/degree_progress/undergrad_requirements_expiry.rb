module CampusSolutions
  module DegreeProgress
    module UndergradRequirementsExpiry
      def self.expire(uids=[])
        uids.each do |uid|
          [::DegreeProgress::UndergradRequirements].each do |klass|
            klass.expire uid
          end
        end
      end
    end
  end
end
