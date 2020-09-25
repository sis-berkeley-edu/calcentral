module HubEdos::ClassesApi::V1
  class Sections
    attr_accessor :course_id
    attr_accessor :term_id

    def initialize(term_id, course_id)
      @course_id = course_id
      @term_id = term_id
    end

    def as_json(options={})
      all
    end

    def all
      @all ||= data.collect do |section_data|
        Section.new(section_data)
      end
    end

    def matching_section_ids(ids)
      all.select do |section|
        ids.include?(section.id.to_s)
      end
    end

    private

    def data
      @data ||= ::HubEdos::ClassesApi::V1::Feeds::SectionsProxy.new(term_id, course_id).get[:feed].fetch('classSections') { [] }
    rescue NoMethodError
      []
    end
  end
end
