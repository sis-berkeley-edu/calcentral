module CampusSolutions
  class MessageCatalog < GlobalCachedProxy
    include ClassLogger

    def self.get_message_catalog_definition(message_set_nbr, message_nbr)
      instance = self.new({message_set_nbr: message_set_nbr, message_nbr: message_nbr})
      response = instance.get
      if response.try(:[], :statusCode) == 200
        return response.try(:[], :feed).try(:[], :root).try(:[], :getMessageCatDefn)
      else
        logger.warn "Failed to obtain message catalog definition: message_set_nbr: #{message_set_nbr}; message_nbr: #{message_nbr}"
      end
      nil
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
