class MediacastsController < ApplicationController

  before_filter :api_authenticate

  def initialize(options = {})
    @options = options
  end

  # GET /api/media/:term_yr/:term_cd/:dept_name/:catalog_id
  def get_media
    # Get enrollments and instructing sections
    uid = session['user_id']
    year = params.require 'term_yr'
    term_code = param_upcase 'term_cd'
    courses = term_courses(uid, year, term_code)

    # Find webcast recordings per section_id
    dept_name = param_upcase 'dept_name'
    catalog_id = param_upcase 'catalog_id'
    sections_ids = extract_sections_ids(courses, dept_name, catalog_id)
    proxy = Webcast::Merged.new uid, course_policy, year, term_code, sections_ids, @options
    render :json => proxy.get_feed
  end

  private

  def term_courses(uid, year, term_code)
    legacy = Berkeley::Terms.legacy? year, term_code
    all_courses = legacy && Settings.features.allow_legacy_fallback ?
      CampusOracle::UserCourses::All.new(user_id: uid).get_all_campus_courses :
      EdoOracle::UserCourses::All.new(user_id: uid).get_all_campus_courses
    all_courses["#{year}-#{term_code}"] || []
  end

  def extract_sections_ids(courses, dept_name, catalog_id)
    return [] if courses.empty?
    courses.select! { |c| c[:dept] == dept_name && c[:catid] == catalog_id }
    sections = courses.collect { |c| c[:sections] }
    sections.flatten.map { |s| s[:ccn].to_i }
  end

  def course_policy
    policy Berkeley::Course.new @options
  end

  def param_upcase(key)
    (params.require key).upcase
  end

end
