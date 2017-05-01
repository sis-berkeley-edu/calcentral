describe Berkeley::LegacyTerms do
  let(:term_id) { '2108' }
  let(:legacy_ccn) { random_id }
  let(:cs_section_id) { random_id }

  describe '#legacy_ccns_to_section_ids' do
    let(:cached_legacy_ccn) { (legacy_ccn.to_i + 1).to_s }
    let(:cached_cs_section_id) { (cs_section_id.to_i + 1).to_s }
    let(:second_legacy_ccn) { (legacy_ccn.to_i + 2).to_s }
    let(:second_cs_section_id) { (cs_section_id.to_i + 2).to_s }
    let(:missing_legacy_ccn) { random_id }
    subject(:mapping) { Berkeley::LegacyTerms.legacy_ccns_to_section_ids(term_id, [legacy_ccn, cached_legacy_ccn, second_legacy_ccn, missing_legacy_ccn]) }
    before do
      Berkeley::LegacyTerms.cache(term_id, cached_cs_section_id, cached_legacy_ccn)
    end
    it 'only makes the necessary queries' do
      expect(CampusOracle::Queries).to receive(:get_sections_from_ccns).with('2010', 'D', [legacy_ccn, second_legacy_ccn, missing_legacy_ccn]).and_return([
        {'dept_name'=>'FIRST DEPT', 'catalog_id'=>'1A', 'term_yr'=>'2010', 'term_cd'=>'D', 'course_cntl_num'=>legacy_ccn, 'section_num'=>'001', 'instruction_format'=>'LEC'},
        {'dept_name'=>'SECOND DEPT', 'catalog_id'=>'2B', 'term_yr'=>'2010', 'term_cd'=>'D', 'course_cntl_num'=>second_legacy_ccn, 'section_num'=>'202', 'instruction_format'=>'GRP'}
      ])
      expect(EdoOracle::Queries).to receive(:get_section_id).with(term_id, 'FIRST DEPT','1A', 'LEC', '001').and_return(cs_section_id)
      expect(EdoOracle::Queries).to receive(:get_section_id).with(term_id, 'SECOND DEPT','2B', 'GRP', '202').and_return(second_cs_section_id)
      expect(Berkeley::LegacyTerms).to receive(:cache).exactly(3).times
      expect(mapping).to include(legacy_ccn => cs_section_id)
      expect(mapping).to include(cached_legacy_ccn => cached_cs_section_id)
      expect(mapping).to include(second_legacy_ccn => second_cs_section_id)
      expect(mapping).to include(missing_legacy_ccn => nil)
    end
  end

  describe '#cache' do
    it 'caches both keys properly' do
      expect(Berkeley::LegacyTerms.fetch_from_cache Berkeley::LegacyTerms.cs_section_id_key(term_id, legacy_ccn)).to be_blank
      expect(Berkeley::LegacyTerms.fetch_from_cache Berkeley::LegacyTerms.legacy_ccn_key(term_id, cs_section_id)).to be_blank
      Berkeley::LegacyTerms.cache(term_id, cs_section_id, legacy_ccn)
      expect(Berkeley::LegacyTerms.fetch_from_cache Berkeley::LegacyTerms.cs_section_id_key(term_id, legacy_ccn)).to eq cs_section_id
      expect(Berkeley::LegacyTerms.fetch_from_cache Berkeley::LegacyTerms.legacy_ccn_key(term_id, cs_section_id)).to eq legacy_ccn
    end
    it 'caches nil values but not nil keys' do
      Berkeley::LegacyTerms.cache(term_id, nil, legacy_ccn)
      expect(Berkeley::LegacyTerms.in_cache? Berkeley::LegacyTerms.cs_section_id_key(term_id, legacy_ccn)).to be_truthy
      expect(Berkeley::LegacyTerms.fetch_from_cache Berkeley::LegacyTerms.cs_section_id_key(term_id, legacy_ccn)).to eq nil
      expect(Berkeley::LegacyTerms.in_cache? Berkeley::LegacyTerms.legacy_ccn_key(term_id, cs_section_id)).to be_falsey
    end
    it 'normalizes padded legacy CCNs' do
      padded_legacy_ccn = "0#{legacy_ccn}"
      Berkeley::LegacyTerms.cache(term_id, cs_section_id, padded_legacy_ccn)
      expect(Berkeley::LegacyTerms.fetch_from_cache Berkeley::LegacyTerms.cs_section_id_key(term_id, legacy_ccn)).to eq cs_section_id
      expect(Berkeley::LegacyTerms.fetch_from_cache Berkeley::LegacyTerms.cs_section_id_key(term_id, legacy_ccn.to_i)).to eq cs_section_id
      expect(Berkeley::LegacyTerms.fetch_from_cache Berkeley::LegacyTerms.cs_section_id_key(term_id, padded_legacy_ccn)).to eq cs_section_id
    end
  end
end
