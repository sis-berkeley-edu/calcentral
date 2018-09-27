module User
  class SearchUsersByNameFilter

    # This module is a Ruby implementation of the Campus Solutions RemoveAccent function.
    # This function is used to modify the input string to create the search criteria for user names and email addresses
    # by converting accented and removing invalid characters.
    # CalCentral implementation will follow the Campus Solutions implementation as closely as possible.
    # https://wikihub.berkeley.edu/display/SIS/CalCentral+View+As+Card

    # character code ranges
    UPPERCASE_CHARACTERS = 65..90
    CJK_RADICALS = 11868..11995
    CJK_SYMBOLS_AND_PUNCTUATION = 12288..12543
    CJK_COMPATIBILITY = 13056..13311
    KATAKANA = 12448..12543
    HIRAGANA = 12352..12447
    ENCLOSED_CJK_LETTERS_AND_MONTHS = 12800..13055
    CJK_UNIFIED_IDEOGRAPHS = 19932..40879
    CJK_UNIFIED_IDEOGRAPHS_EXT = 13312..19903

    CHARACTER_CODES = [UPPERCASE_CHARACTERS, CJK_RADICALS, CJK_SYMBOLS_AND_PUNCTUATION, CJK_COMPATIBILITY, KATAKANA,
                       HIRAGANA, ENCLOSED_CJK_LETTERS_AND_MONTHS, CJK_UNIFIED_IDEOGRAPHS, CJK_UNIFIED_IDEOGRAPHS_EXT]

    DIACRITICS = {
      'A': ['â', 'à', 'á', 'ã', 'æ', 'å', 'Å', 'À', 'Á', 'Â', 'Ã', 'Æ', 'ä', 'Ä'],
      'C': ['Ç', 'ç'],
      'D': ['ð', 'Ð'],
      'E': ['é', 'ê', 'ë', 'è', 'É', 'È', 'Ê', 'Ë'],
      'I': ['ï', 'î', 'ì', 'í', 'Ì', 'Í', 'Î', 'Ï'],
      'N': ['ñ', 'Ñ'],
      'O': ['ô', 'ò', 'ó', 'õ', 'ø', 'Ò', 'Ó', 'Ô', 'Õ', 'Ø', 'ö', 'Ö'],
      'SS': ['ß'],
      'T': ['þ', 'Þ'],
      'U': ['û', 'ù', 'ú', 'Ù', 'Ú', 'Û', 'Ü', 'ü'],
      'Y': ['ý', 'ÿ', 'Ý']
    }

    def initialize
      @diacritics_map = {}.tap do |diacritics_hash|
        DIACRITICS.each do |alphabetical, diacritics_array|
          diacritics_array.each { |diacritic| diacritics_hash.merge!([[diacritic, alphabetical]].to_h) }
        end
      end
    end

    def prepare_for_query(encoded_uri='')
      decoded_uri = CGI::unescape(encoded_uri)
      uppercase = decoded_uri.upcase
      processed = ''

      uppercase.each_char { |character| processed << process_character(character).to_s }
      replace_spaces_with_wildcards(processed)
    end

    def process_character(char)
      if is_valid_unicode?(char)
        return char
      elsif is_diacritic?(char)
        return @diacritics_map.fetch(char)
      elsif is_wildcard?(char)
        return ''
      else
        return char.gsub(/[^0-9a-z ]/i, '')
      end
    end

    def is_diacritic?(char)
      @diacritics_map.has_key?(char)
    end

    def is_valid_unicode?(char)
      ordinal = char.ord
      CHARACTER_CODES.any? { |utf_range| utf_range.cover? ordinal }
    end

    def is_wildcard?(char)
      [',', '%', '_', '\\'].include?(char)
    end

    def replace_spaces_with_wildcards(str)
      str.gsub(' ', '%')
    end

  end
end
