describe User::Academics::DegreeProgress::Queries do
  let(:emplid) { '11667051' }
  describe '#candidacy_term_stats' do
    it 'returns candidacy term statistics' do
      result = described_class.candidacy_term_status(emplid)
      expect(result.count).to eq 1
      expect(result.first['emplid']).to eq '11667051'
      expect(result.first['acad_career']).to eq 'GRAD'
      expect(result.first['acad_prog']).to eq 'GACAD'
      expect(result.first['acad_plan']).to eq '79249PHDG'
      expect(result.first['acad_sub_plan']).to eq '79249SP09G'
      expect(result.first['candidacy_end_term']).to eq '2202'
      expect(result.first['candidacy_status_code']).to eq 'G'
    end
  end
end
