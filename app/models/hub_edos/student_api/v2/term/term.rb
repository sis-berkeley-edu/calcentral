module HubEdos
  module StudentApi
    module V2
      module Term
        # A Term is a time period at the end of which academic credit is granted.
        class Term
          def initialize(data)
            @data = data || {}
          end

          # a short string used to identify the term
          def id
            @data['id']
          end

          # the short name of the term
          def name
            @data['name']
          end

          # a short descriptor representing the term\'s type: "Regular" (i.e. fall or spring) or "Summer,"
          def category
            ::HubEdos::Common::Reference::Descriptor.new(@data['category']) if @data['category']
          end

          # a component that describes the highest level grouping of academic policy
          def academic_career
            @data['academicCareer']
          end

          # the term's place in time: Past, Previous, Current, Next, or Future
          def temporal_position
            @data['temporalPosition']
          end

          # a single four-digit year associated with the term	string
          def academic_year
            @data['academicYear']
          end

          # the date the term officially begins
          def begin_date
            @begin_date ||= begin
              date_string = @data['beginDate']
              Date.parse(date_string) if date_string
            end
          end

          # the date the term officially ends
          def end_date
            @end_date ||= begin
              date_string = @data['endDate']
              Date.parse(date_string) if date_string
            end
          end

          # the number of weeks during the term when instruction will occur
          def weeks_of_instruction
            @data['weeksOfInstruction'].to_i if @data['weeksOfInstruction']
          end

          # a short descriptor representing the holidays within the term
          def holiday_schedule
            ::HubEdos::Common::Reference::Descriptor.new(@data['holidaySchedule']) if @data['holidaySchedule']
          end

          # the date on which enrollment census for the term is taken
          def census_date
            @census_date ||= begin
              date_string = @data['censusDate']
              Date.parse(date_string) if date_string
            end
          end

          def as_json(options={})
            {
              id: id,
              name: name,
              category: category,
              academicCareer: academic_career,
              temporalPosition: temporal_position,
              academicYear: academic_year,
              beginDate: begin_date,
              endDate: end_date,
              weeksOfInstruction: weeks_of_instruction,
              holidaySchedule: holiday_schedule,
              censusDate: census_date
            }.compact
          end

        end
      end
    end
  end
end
