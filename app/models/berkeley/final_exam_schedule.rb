module Berkeley
  class FinalExamSchedule
    extend Cache::Cacheable
    include ClassLogger

    def self.fetch
      fetch_from_cache do
        course_to_exam = {}
        Settings.final_exam_schedule.each do |settings|
          if (csv_per_term = settings.marshal_dump[:csv_per_term])
            csv_per_term.marshal_dump.each do |term_code, path|
              logger.warn "Loading #{settings.year}#{term_code} final exam schedule from #{path}"
              course_to_exam.merge! parse_csv(settings.year, term_code, path)
            end
          end
        end
        course_to_exam
      end
    end

    # processes each semester from the CSV, assigning each key to the hash.
    def self.parse_csv(year, term_code, csv)
      result = {}
      CSV.foreach(csv,{:headers=>true}) do |row|
        exam = {
          year: year,
          term_code: term_code,
          exam_day: row['Day'],
          exam_time: row['Time'],
          exam_slot: row['Exam Group']
        }
        times, days, courses = row['Class Times'], row['Class Days'], row['Course Exceptions']

        days && days.split(/(?=[A-Z])/).each do |day|
          if times
            times.split(' ').each do |time|
              result["#{term_code}-#{day}-#{time}"] = exam
            end
          else
            # Weekends
            result["#{term_code}-#{day}"] = exam unless times
          end
        end
        # Key per course code, e.g B-CHEM 1A
        courses && courses.split(', ').each { |course| result["#{term_code}-#{course}"] = exam }
      end
      result
    end

  end
end
