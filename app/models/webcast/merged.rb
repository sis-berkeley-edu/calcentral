module Webcast
  class Merged < UserSpecificModel
    include Cache::CachedFeed

    def initialize(uid, course_policy, term_yr, term_cd, ccn_list, options = {})
      super(uid.nil? ? nil : uid.to_i, options)
      @term_yr = term_yr.to_i unless term_yr.nil?
      @term_cd = term_cd
      @ccn_list = ccn_list
      @options = options
      @course_policy = course_policy
    end

    def get_feed_internal
      logger.warn "Webcast merged feed where year=#{@term_yr}, term=#{@term_cd}, ccn_list=#{@ccn_list.to_s}, course_policy=#{@course_policy.to_s}"
      @academics = MyAcademics::Teaching.new(@uid)
      get_media_feed
    end

    private

    def get_media_feed
      media = get_media
      if media.any?
        media_hash = {
          :media => media,
          :videos => merge(media, :videos)
        }
      else
        {}
      end
    end

    def get_media
      feed = []
      if @term_yr && @term_cd
        media_per_ccn = Webcast::CourseMedia.new(@term_yr, @term_cd, @ccn_list, @options).get_feed
        if media_per_ccn.any?
          courses = @academics.courses_list_from_ccns(@term_yr, @term_cd, media_per_ccn.keys)
          courses.each do |course|
            course[:classes].each do |next_class|
              next_class[:sections].each do |section|
                ccn = section[:ccn]
                section_metadata = {
                  termYr: @term_yr,
                  termCd: @term_cd,
                  ccn: ccn,
                  deptName: next_class[:dept],
                  catalogId: next_class[:courseCatalog],
                  instructionFormat: section[:instruction_format],
                  sectionNumber: section[:section_number]
                }
                media = media_per_ccn[ccn.to_i]
                feed << media.merge(section_metadata) if media
              end
            end
          end
        end
      end
      feed
    end

    def instance_key
      if @term_yr && @term_cd
        "#{Webcast::CourseMedia.id_per_ccn(@term_yr, @term_cd, @ccn_list.to_s)}/#{@uid}"
      else
        @uid
      end
    end

    def merge(media_per_ccn, media_type)
      all_recordings = Set.new
      media_per_ccn.each do |section|
        recordings = section[media_type]
        recordings.each { |r| all_recordings << r } if recordings
      end
      all_recordings.to_a
    end

  end
end
