module CanvasLti
  class ToggleSisLtiTools
    include ClassLogger

    def initialize(options = {})
      settings = {
        to_term: '2016-C',
        from_term: '2013-C',
        hide_them: true
      }.merge options
      @newest_term = settings[:to_term]
      @oldest_term = settings[:from_term]
      @hide_them = settings[:hide_them]
    end

    def run
      @tool_ids = get_sis_dependent_tool_ids
      total_sites_changed = 0
      logger.warn "Will change tools hidden=#{@hide_them} for terms from #{@oldest_term} to #{@newest_term}"
      get_canvas_term_ids(@newest_term, @oldest_term).each do |canvas_term_id|
        sites_changed = loop_sites_in_term canvas_term_id
        total_sites_changed += sites_changed
      end
      logger.warn "Set tools hidden=#{@hide_them} in #{total_sites_changed} sites"
    end

    def get_sis_dependent_tool_ids
      official_course_tools = Canvas::ExternalTools.public_list[:officialCourseTools]
      official_course_tools.slice('Official Sections', 'Roster Photos').values
    end

    def get_canvas_term_ids(newest_term_code, oldest_term_code)
      canvas_term_ids = []
      Canvas::Terms.fetch.each do |canvas_term|
        if (term = Canvas::Terms.sis_term_id_to_term canvas_term['sis_term_id'])
          term_code = "#{term[:term_yr]}-#{term[:term_cd]}"
          if term_code <= newest_term_code && term_code >= oldest_term_code
            canvas_term_ids << canvas_term['id']
          end
        end
      end
      canvas_term_ids
    end

    def loop_sites_in_term(canvas_term_id)
      response = Canvas::Course.new.official_courses canvas_term_id
      courses = response[:body]
      logger.warn "Will loop around #{courses.length} course sites for Canvas term #{canvas_term_id}"
      updates = 0
      courses.each do |course|
        if update_course_site_tabs course['id']
          updates += 1
        end
      end
      updates
    end

    def update_course_site_tabs(canvas_course_id)
      updated = false
      proxy = Canvas::ExternalTools.new(canvas_course_id: canvas_course_id)
      tab_list = proxy.course_site_tab_list
      @tool_ids.each do |tool_id|
        tab = tab_list.find { |tab| tab['id'].end_with? "_#{tool_id}" }
        if !!tab['hidden'] != @hide_them
          proxy.update_course_site_tab_hidden(tab, @hide_them)
          updated = true
        end
      end
      updated
    end

  end
end
