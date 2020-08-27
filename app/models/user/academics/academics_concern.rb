module User
  module Academics
    module AcademicsConcern
      extend ActiveSupport::Concern

      included do
        def diploma
          @diploma ||= ::User::Academics::Diploma.new(self)
        end

        def enrollment_terms
          @enrollment_terms ||= ::User::Academics::EnrollmentTerms.new(self)
        end

        def enrollment_term_instructions
          @enrollment_term_instructions ||= ::User::Academics::EnrollmentTermInstructions.new(self)
        end

        def holds
          @holds ||= ::User::Academics::Holds.new(self)
        end

        def registrations
          @registrations ||= ::User::Academics::Registrations.new(self)
        end

        def status_and_holds
          @status_and_holds ||= ::User::Academics::StatusAndHolds.new(self)
        end

        def student_attributes
          @student_attributes ||= ::User::Academics::StudentAttributes.new(self)
        end

        def student_groups
          @student_groups ||= ::User::Academics::StudentGroups.new(self)
        end

        def term_registrations
          @term_registrations ||= ::User::Academics::TermRegistrations.new(self)
        end

        def term_plans
          @term_plans ||= ::User::Academics::TermPlans::TermPlans.new(self)
        end
      end
    end
  end
end
