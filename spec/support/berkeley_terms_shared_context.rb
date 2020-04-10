shared_context 'stubbed Berkeley::Terms' do
  before do
    allow(EdoOracle::Queries).to receive(:get_undergrad_terms).and_return(undergrad_terms)
  end
  let(:undergrad_terms) { term_data.select { |term| term['career_code'] == 'UGRD' } }
  let(:term_data) do
    [
      {
        "career_code" => "UGRD",
        "term_id" => "2168",
        "term_type" => "Fall",
        "term_year" => "2016",
        "term_code" => "D",
        "term_descr" => "Fall 2016",
        "term_begin_date" => Date.parse('Sun, 17 Jan 2016'),
        "term_end_date" => Date.parse('Sat, 16 Jan 2016'),
        "class_begin_date" => nil,
        "class_end_date" => nil,
        "instruction_end_date" => nil,
        "grades_entered_date" => nil,
        "end_drop_add_date" => nil,
        "is_summer" => "N",
      }
    ]
  end
end
