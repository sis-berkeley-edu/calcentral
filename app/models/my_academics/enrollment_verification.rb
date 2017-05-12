module MyAcademics
  class EnrollmentVerification < UserSpecificModel
    include LinkFetcher

    def get_feed_as_json
      get_feed.to_json
    end

    def get_feed
      {
        messages: enrollment_verification_messages,
        requestUrl: enrollment_verification_request_link,
        academicRoles: HubEdos::MyAcademicStatus.get_roles(@uid),
      }
    end

    def enrollment_verification_messages
      messages = CampusSolutions::EnrollmentVerificationMessages.new().get
      return {errored: true} if (messages[:statusCode] != 200)
      messages.try(:[], :feed).try(:[], :root).try(:[], :getMessageCatDefn)
    end

    def enrollment_verification_request_link
      fetch_link('UC_CX_SS_ENRL_VER_REQ', {})
    end
  end
end
