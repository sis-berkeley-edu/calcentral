describe Berkeley::FinalExamSchedule do

  let(:schedule) do
    Berkeley::FinalExamSchedule.fetch
  end

  context 'as a student' do
    it 'should parse the csvs correctly' do
      # Fall
      b_m = schedule['B-M-8:00A']
      expect(b_m[:exam_day]).to eq 'Monday'
      expect(b_m[:exam_time]).to eq '8-11A'
      expect(b_m[:exam_slot]).to eq '1'
      b_w = schedule['B-W-8:00A']
      expect(b_w[:exam_day]).to eq 'Monday'
      expect(b_w[:exam_time]).to eq '8-11A'
      expect(b_w[:exam_slot]).to eq '1'
      b_chem = schedule['B-CHEM 1A']
      expect(b_chem[:exam_day]).to eq 'Wednesday'
      expect(b_chem[:exam_time]).to eq '8-11A'
      expect(b_chem[:exam_slot]).to eq '9'
      b_f = schedule['B-F-7:00P']
      expect(b_f[:exam_day]).to eq 'Friday'
      expect(b_f[:exam_time]).to eq '3-6P'
      expect(b_f[:exam_slot]).to eq '19'
      # Spring
      d_w = schedule['D-W-8:00A']
      expect(d_w[:exam_day]).to eq 'Monday'
      expect(d_w[:exam_time]).to eq '7-10P'
      expect(d_w[:exam_slot]).to eq '4'
      d_french = schedule['D-FRENCH 2']
      expect(d_french[:exam_day]).to eq 'Wednesday'
      expect(d_french[:exam_time]).to eq '11:30-2:30P'
      expect(d_french[:exam_slot]).to eq '10'
      d_sa = schedule['D-Sa']
      expect(d_sa[:exam_day]).to eq 'Wednesday'
      expect(d_sa[:exam_time]).to eq '3-6P'
      expect(d_sa[:exam_slot]).to eq '11'
    end
  end

end
