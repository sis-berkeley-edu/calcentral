module Rosters
  module TableColumns
    extend self

    def get_students_with_columns_and_headers(students)
      student_section_columns = get_student_section_columns(students)
      student_columns = student_section_columns[:student_columns]
      students.each do |student|
        student[:columns] = student_columns[student[:student_id]]
      end
      {
        headers: student_section_columns[:headers],
        students: students
      }
    end

    def get_student_section_columns(students)
      students_with_columns_hash = get_student_section_columns_hash(students)
      section_headers_prototype = get_section_headers_prototype(students_with_columns_hash)
      section_headers = get_section_headers(section_headers_prototype)
      student_columns = get_student_columns(section_headers_prototype, students_with_columns_hash)
      {
        headers: section_headers,
        student_columns: student_columns
      }
    end

    def get_student_columns(section_headers_prototype, students_with_columns_hash)
      student_columns = {}
      students_with_columns_hash.each do |student_id, student_columns_hash|
        student_columns[student_id] = []
        section_headers_prototype_iterator(section_headers_prototype) do |header_column_hash, index|
          instruction_format = header_column_hash[:instruction_format]
          primary_group_key = header_column_hash[:primary_group_key]
          sections = student_columns_hash.try(:[], primary_group_key).try(:[], instruction_format).to_a
          ordered_sections = sections.collect {|sec| sec[:section_number]}.sort
          student_column = header_column_hash.merge({section_number: ordered_sections[index]})
          student_columns[student_id].push(student_column)
        end
      end
      student_columns
    end

    def get_section_headers(section_headers_prototype)
      section_headers = []
      section_headers_prototype_iterator(section_headers_prototype) do |header_column_hash|
        section_headers.push(header_column_hash)
      end
      section_headers
    end

    # Used to iterate over columns hash
    def section_headers_prototype_iterator(section_headers_prototype, &block)
      section_headers_prototype.each do |header_column_config|
        header_column_config[:columns].times do |index|
          yield(header_column_config.slice(:instruction_format, :primary_group_key), index)
        end
      end
    end

    def get_section_headers_prototype(students_with_columns_hash)
      headers_prototype = []
      max_column_count_hash = {}

      students_with_columns_hash.keys.each do |sid|
        columns_hash = students_with_columns_hash[sid]
        # sort automatically makes primary before secondary
        columns_hash.keys.sort.each do |primary_group_key|
          instruction_format_groups = columns_hash[primary_group_key]
          instruction_format_groups.keys.sort.each do |instruction_format_code|
            sections = instruction_format_groups[instruction_format_code]

            column_key = {if: instruction_format_code, pgk: primary_group_key}
            max_column_count_hash[column_key] ||= 0

            current_value = max_column_count_hash[column_key]
            max_column_count_hash[column_key] = sections.count > current_value ? sections.count : current_value
          end
        end
      end

      max_column_count_hash.each do |key, value|
        column = {
          :instruction_format => key[:if],
          :primary_group_key => key[:pgk],
          :columns => value
        }
        headers_prototype.push(column)
      end
      headers_prototype
    end

    # Provides hash representing students and enrolled sections
    def get_student_section_columns_hash(students)
      students.inject({}) do |map, student|
        map[student[:student_id]] = section_columns_hash(student[:sections])
        map
      end
    end

    # Converts student sections into data structure used to build column data sets
    # Returns hash representing sections categorized by primary/secondary status and instructional format
    def section_columns_hash(sections)
      section_property_filter = [:instruction_format, :is_primary, :section_number]
      columns_hash = {}
      primary_groups = sections.group_by { |section| section.try(:[], :is_primary) ? :primary : :secondary }
      primary_groups.keys.each do |primary_group_key|
        columns_hash[primary_group_key] = {}
        primary_group = primary_groups[primary_group_key]
        instructional_format_groups = primary_group.group_by { |sec| sec[:instruction_format] }
        instructional_format_groups.keys.each do |instruction_format_code|
          if_sections = instructional_format_groups[instruction_format_code]
          columns_hash[primary_group_key][instruction_format_code] = if_sections.collect {|sec| sec.slice(*section_property_filter)}
        end
      end
      columns_hash
    end

  end
end
