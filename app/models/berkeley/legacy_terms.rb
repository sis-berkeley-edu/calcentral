module Berkeley
  class LegacyTerms
    include ClassLogger
    extend Cache::Cacheable

    # When pre-Fall-2016 course section data was migrated to the CS DB, the original section Course Control Numbers
    # were not included. Since external SIS-integrated resources frequently relied on CCNs as a unique section ID,
    # this utility class provides a programmatic mapping.

    def self.legacy_ccns_to_section_ids(cs_term_id, legacy_ccns)
      mapping = {}
      remaining = []
      legacy_ccns.each do |legacy_ccn|
        legacy_ccn = normalized(legacy_ccn)
        ckey = cs_section_id_key(cs_term_id, legacy_ccn)
        # We may have cached a nil value; i.e., there is no match and no need to query again.
        if in_cache? ckey
          mapping[legacy_ccn] = fetch_from_cache ckey
        else
          remaining << legacy_ccn
        end
      end
      if remaining.present?
        term_yr, term_cd = Berkeley::TermCodes.from_edo_id(cs_term_id).values
        legacy_sections = self.get_sections_from_legacy_ccns(term_yr, term_cd, remaining)
        legacy_sections.each do |section|
          legacy_ccn = section['ccn']
          cs_section_id = EdoOracle::Queries.get_section_id(cs_term_id,
            section['dept_name'], section['catalog_id'], section['instruction_format'], section['section_num'])
          if cs_section_id.blank?
            logger.warn "No CS DB equivalent found for term #{cs_term_id}, legacy CCN #{legacy_ccn}, #{section['dept_name']} #{section['catalog_id']} #{section['instruction_format']} #{section['section_num']}"
          end
          mapping[legacy_ccn] = cs_section_id
          cache(cs_term_id, cs_section_id, legacy_ccn)
          remaining.delete legacy_ccn
        end
        remaining.each do |legacy_ccn|
          logger.warn "No legacy DB section found for term #{cs_term_id}, legacy CCN #{legacy_ccn}"
          mapping[legacy_ccn] = nil
          cache(cs_term_id, nil, legacy_ccn)
        end
      end
      mapping
    end

    def self.get_sections_from_legacy_ccns(term_yr, term_cd, legacy_ccns)
      results = []
      sections = CSV.read('public/csv/legacy_ccn_mappings.csv', headers: true)
      legacy_ccns.each do |ccn|
        key = "#{term_yr}-#{term_cd}-#{ccn}"
        if (section_def = sections.find {|s| s['term_ccn'] == key})
          results << section_def.to_h.merge('ccn' => ccn)
        end
      end
      results
    end

    def self.cs_section_id_key(cs_term_id, legacy_ccn)
      "#{cs_term_id}-#{normalized(legacy_ccn)}/CS_SECTION_ID"
    end

    def self.legacy_ccn_key(cs_term_id, cs_section_id)
      "#{cs_term_id}-#{cs_section_id}/LEGACY_CCN"
    end

    def self.cache(cs_term_id, section_id, legacy_ccn)
      write_cache(section_id, cs_section_id_key(cs_term_id, legacy_ccn)) if legacy_ccn.present?
      write_cache(normalized(legacy_ccn), legacy_ccn_key(cs_term_id, section_id)) if cs_term_id.present?
    end

    def self.normalized(legacy_ccn)
      if legacy_ccn.present?
        # Normalize to deal with legacy zero-padding in some legacy systems.
        legacy_ccn.to_i.to_s
      else
        legacy_ccn
      end
    end

  end
end
