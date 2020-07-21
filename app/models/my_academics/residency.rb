module MyAcademics
  class Residency < UserSpecificModel
    include Cache::CachedFeed
    include Cache::UserCacheExpiry

    def get_feed_internal
      residency = get_hub_residency
      # Add residency.message.code to the response
      if message_code = get_residency_message_code(residency)
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

    def get_hub_residency
      cs_demographics = HubEdos::StudentApi::V2::Feeds::Demographics.new(user_id: @uid).get
      residency = cs_demographics.try(:[], :feed).try(:[], 'residency')
      return {} if residency.blank? || residency['fromTerm'].blank?
      residency = HashConverter.symbolize residency

      residency[:fromTerm][:label] = Berkeley::TermCodes.normalized_english(residency[:fromTerm][:name])
      residency
    end

    def get_residency_message_code(residency)
      slr_status = residency[:statementOfLegalResidenceStatus].try(:[], :code)
      official_status = residency[:official].try(:[], :code)
      tuition_exception = residency[:tuitionException].try(:[], :code)
      Berkeley::ResidencyMessageCode.residency_message_code(slr_status, official_status, tuition_exception)
    end
  end
end
