class HubEdos::ClassesApi::V1::Feeds::SectionsProxy < ::HubEdos::ClassesApi::V1::Feeds::Proxy
  include HubEdos::CachedProxy

  attr_accessor :term_id, :course_id

  def initialize(term_id, course_id)
    @term_id = term_id
    @course_id = course_id
  end

  def instance_key
    "#{term_id}-#{course_id}"
  end

  def url
    "#{settings.base_url}/v1/classes/sections?cs-course-id=#{course_id}&term-id=#{term_id}"
  end

  def whitelist_fields
    ['classSections']
  end
end
