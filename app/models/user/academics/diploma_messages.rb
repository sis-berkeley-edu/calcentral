# Provides message catalog entries related to diploma card as well as
# indication of diploma term support
class User::Academics::DiplomaMessages
  MESSAGE_CATALOG_SET = 28510

  def initialize(term_ids)
    @term_ids = term_ids || []
  end

  def paper_diploma_message
    CampusSolutions::MessageCatalog.get_message_by(set: MESSAGE_CATALOG_SET, number: 1)
  end

  def electronic_diploma_notice_message
    CampusSolutions::MessageCatalog.get_message_by(set: MESSAGE_CATALOG_SET, number: 2)
  end

  def electronic_diploma_ready_message
    CampusSolutions::MessageCatalog.get_message_by(set: MESSAGE_CATALOG_SET, number: 3)
  end

  def electronic_diploma_help_message
    term_help_messages[greatest_supported_term]
  end

  def greatest_supported_term
    supported_terms.sort.last
  end

  # indicates terms supported based on message catalog entry presence
  def supported_terms
    term_help_messages.keys
  end

  def term_help_messages
    @term_help_messages ||= @term_ids.inject({}) do |map, term_id|
      message = CampusSolutions::MessageCatalog.get_message_by(set: MESSAGE_CATALOG_SET, number: term_id.to_i)
      map[term_id] = message if message.present?
      map
    end
  end
end
