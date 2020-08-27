module HubEdos
  module StudentApi
    module V2
      module Student
        # An Award/Honor is a recognition of extraordinary performance or achievement
        class AwardHonor
          def initialize(data)
            @data = data || {}
          end

          # a short descriptor representing the kind of award or honor, such as dean's list, etc.
          def type
            ::HubEdos::Common::Reference::Descriptor.new(@data['type']) if @data['type']
          end

          # the person or party giving the award or honor
          def grantor
            @data['grantor']
          end

          # the date on which the award or honor is given
          def award_date
            @from_date ||= begin
              Date.parse(@data['awardDate']) if @data['awardDate']
            end
          end

          # a component that describes the institution associated with the award or honor
          def institution
            ::HubEdos::StudentApi::V2::StudentRecord::Institution.new(@data['institution']) if @data['institution']
          end

          # a component that describes the career associated with the award or honor
          def academic_career
            ::HubEdos::Common::Reference::Descriptor.new(@data['academicCareer']) if @data['academicCareer']
          end

          # a component that describes the program associated with the award or honor
          def academic_program
            ::HubEdos::StudentApi::V2::AcademicPolicy::AcademicProgram.new(@data['academicProgram']) if @data['academicProgram']
          end

          # a component that describes the plan associated with the award or honor
          def academic_plan
            ::HubEdos::StudentApi::V2::AcademicPolicy::AcademicPlan.new(@data['academicPlan']) if @data['academicPlan']
          end

          # a component that describes the term associated with the award or honor
          attr_accessor :term
          def term
            ::HubEdos::StudentApi::V2::Term::Term.new(@data['term']) if @data['term']
          end

          # free form comments concerning the award or honor
          def comments
            @data['comments']
          end

        end
      end
    end
  end
end
