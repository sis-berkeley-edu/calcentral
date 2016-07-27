module CampusSolutions
  class EnrollmentVerificationDeeplink < CachedProxy

    def initialize(options = {})
      super options
    end

    def get_internal
        build_feed
    end

    def build_feed()
      return {} unless Settings.features.enrollment_verification_deeplink
      {
        feed: {
          name: "Enrollment Verification",
          url: Settings.campus_solutions_links.academics.enrollment_verification,
          isCsLink: true
        }
      }
    end

    def json_filename
      'enrollment_verification_deeplink.json'
    end

  end
end
