module CampusSolutions
  class MessageCatalog < GlobalCachedProxy
    include ClassLogger

    # We want to keep an inventory of messages used by CalCentral here
    CATALOG = {
      academic_standings_learn_more: { message_set_nbr: '28000', message_nbr: '213' },
      final_exams_term_begin: { message_set_nbr: '32500', message_nbr: '110' },
      financial_aid_gift_aid_more_info: { message_set_nbr: '26400', message_nbr: '1' },
      financial_aid_net_cost_more_info: { message_set_nbr: '26400', message_nbr: '3' },
      financial_aid_third_party_more_info: { message_set_nbr: '26400', message_nbr: '2' },
      financial_aid_awards_card_info: { message_set_nbr: '26500', message_nbr: '115' },
      financial_aid_awards_card_info_est_disbursements: { message_set_nbr: '26400', message_nbr: '5'},
      financial_aid_awards_card_auth_failed: { message_set_nbr: '26400', message_nbr: '6'},
      financial_aid_housing_instruction_generic: { message_set_nbr: '26500', message_nbr: '117' },
      financial_aid_housing_instruction_fall_pathways: { message_set_nbr: '26500', message_nbr: '116' },
      financial_aid_housing_instruction_spring_pathways: { message_set_nbr: '26500', message_nbr: '118' },
      graduation_recommended: { message_set_nbr: '28000', message_nbr: '212' },
      graduation_required: { message_set_nbr: '28000', message_nbr: '210' },
      graduation_with_loans: { message_set_nbr: '28000', message_nbr: '211' },
      pnp_calculator_ratio: { message_set_nbr: '32000', message_nbr: '17' },
      waitlisted_units_warning: { message_set_nbr: '28000', message_nbr: '216' },
    }

    def self.get_message(message_key)
      if message_id = CATALOG[message_key]
        message_set_nbr = message_id[:message_set_nbr]
        message_nbr = message_id[:message_nbr]
        instance = self.new({message_set_nbr: message_set_nbr, message_nbr: message_nbr})
        response = instance.get
        if response.try(:[], :statusCode) == 200
          return response.try(:[], :feed).try(:[], :root).try(:[], :getMessageCatDefn)
        else
          logger.warn "Failed to obtain message catalog definition: message_set_nbr: #{message_set_nbr}; message_nbr: #{message_nbr}"
        end
      end
      nil
    end

    def self.get_message_collection(message_keys)
      messages = {}
      message_keys.each do |key|
        message = CampusSolutions::MessageCatalog.get_message(key)
        messages[key] = message unless message.blank?
      end
      messages
    end

    def initialize(options = {})
      super options
      @message_set_nbr = options[:message_set_nbr]
      @message_nbr = options[:message_nbr]
      initialize_mocks if @fake
    end

    def xml_filename
      'message_catalog.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def instance_key
      @message_nbr.present? ? "#{@message_set_nbr}-#{@message_nbr}" : "#{@message_set_nbr}"
    end

    def url
      message_nbr_param = @message_nbr ? "&MESSAGE_NBR=#{@message_nbr}" : ''
      "#{@settings.base_url}/UC_CC_MESSAGE_CATALOG.v1/get?MESSAGE_SET_NBR=#{@message_set_nbr}#{message_nbr_param}"
    end

  end
end
