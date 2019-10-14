module User
  module Academics
    class Registration
      attr_reader :data

      LAW = 'LAW'
      GRADUATE = 'GRAD'
      UNDERGRADUATE = 'UGRD'

      def initialize(registration_data)
        @data = registration_data
      end

      def term_id
        data['term']['id']
      end

      def term
        Berkeley::Terms.find_by_campus_solutions_id(term_id)
      end

      def undergraduate?
        career_code == UNDERGRADUATE
      end

      def graduate?
        career_code == GRADUATE
      end

      def law?
        career_code == LAW
      end

      def academic_levels
        ::User::Academics::Levels.new(data['academicLevels'])
      end

      def preferred_level
        career_preferred_type_code = career_code == 'LAW' ? 'EOT' : 'BOT'
        academic_levels.all.find {|al| al.type_code == career_preferred_type_code }
      end

      def career_code
        data['academicCareer']['code']
      end

      def career_description
        data['academicCareer']['description']
      end

      def total_units_taken
        unit_totals.fetch('unitsTaken') { 0 }
      end

      def total_units_enrolled
        unit_totals.fetch('unitsEnrolled') { 0 }
      end

      def unit_totals
        data['termUnits'].select do |term|
          term['type']['code'] == 'Total'
        end.first || {}
      end

      def enrolled?
        total_units_enrolled > 0 || total_units_taken > 0
      end
    end
  end
end
