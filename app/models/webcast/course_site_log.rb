module Webcast
  class CourseSiteLog < ApplicationRecord

    self.table_name = 'webcast_course_site_log'

    attr_accessible :canvas_course_site_id, :webcast_tool_unhidden_at

  end
end
