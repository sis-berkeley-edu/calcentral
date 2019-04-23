module MyAcademics
  class Residency < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      cs_demographics = HubEdos::Demographics.new(user_id: @uid).get
      residency = cs_demographics.try(:[], :feed).try(:[], 'student').try(:[], 'residency')
      return {} if residency.blank? || residency['fromTerm'].blank?
      residency = HashConverter.symbolize residency

      # Add residency.fromTerm.label to the response
      residency[:fromTerm][:label] = Berkeley::TermCodes.normalized_english(residency[:fromTerm][:name])

      # Add residency.message.code to the response
      slr_status = residency[:statementOfLegalResidenceStatus].try(:[], :code)
      official_status = residency[:official].try(:[], :code)
      tuition_exception = residency[:tuitionException].try(:[], :code)
      if (message_code = Berkeley::ResidencyMessageCode.residency_message_code(slr_status, official_status, tuition_exception))
        residency[:message] = {code: message_code}
        # Having unearthed the code, use it to fetch the message text.
        decoded_message = CampusSolutions::ResidencyMessage.new(messageNbr: message_code).get
        message_definition = decoded_message.try(:[], :feed).try(:[], :root).try(:[], :getMessageCatDefn)
        if message_definition.present?
          residency[:message].merge!(
            description: message_definition[:descrlong],
            label: message_definition[:messageText],
            setNumber: message_definition[:messageSetNbr]
          )
        end
      end
      {
        residency: residency
      }
    end
  end
end
