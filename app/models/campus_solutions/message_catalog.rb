module CampusSolutions
  class MessageCatalog < GlobalCachedProxy
    include ClassLogger

    CATALOG = YAML.load_file(Rails.root.join("config", "message_catalog.yml"))
                  .with_indifferent_access

    def self.get_message(message_key)
      message_id = CATALOG[message_key]
      return nil unless message_id
      self.get_message_by(set: message_id.first, number: message_id.last)
    end

    def self.get_message_by(set: , number:)
      instance = self.new({ message_set_nbr: set, message_nbr: number})
      instance.message_definition
    end

    def self.get_message_collection(message_keys)
      messages = {}
      message_keys.each do |key|
        message = CampusSolutions::MessageCatalog.get_message(key)
        messages[key] = message unless message.blank?
      end
      messages
    end

    attr_reader :message_set_nbr, :message_nbr

    def initialize(options = {})
      super options
      @message_set_nbr = options[:message_set_nbr]
      @message_nbr = options[:message_nbr]
      initialize_mocks if @fake
    end

    def message_definition
      return @message_definition if defined? @message_definition

      response = get

      if response.try(:[], :statusCode) == 200
        @message_definition = response.try(:[], :feed).try(:[], :root).try(:[], :getMessageCatDefn)
        return @message_definition
      end

      logger.warn "Failed to obtain message catalog definition: message_set_nbr: #{message_set_nbr}; message_nbr: #{message_nbr}"
      return nil
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
