describe Berkeley::TermCodes do

  describe "EDO database conversions" do
    it "should convert code and year into EDO term id" do
      expect(Berkeley::TermCodes.to_edo_id("2013", "B")).to eq "2132"
      expect(Berkeley::TermCodes.to_edo_id("2002", "C")).to eq "2025"
      expect(Berkeley::TermCodes.to_edo_id("2016", "D")).to eq "2168"
    end

    it "should convert EDO term id to legacy term hash" do
      result = Berkeley::TermCodes.from_edo_id('2132')
      expect(result[:term_yr]).to eq '2013'
      expect(result[:term_cd]).to eq 'B'

      result = Berkeley::TermCodes.from_edo_id('2028')
      expect(result[:term_yr]).to eq '2002'
      expect(result[:term_cd]).to eq 'D'
    end

    it 'should accept integer input' do
      expect(Berkeley::TermCodes.to_edo_id(2013, 'B')).to eq '2132'
      expect(Berkeley::TermCodes.from_edo_id(2028)).to eq({
        term_yr: '2002',
        term_cd: 'D'
      })
    end

    it 'should indicate if EDO term id indicates a summer term' do
      expect(Berkeley::TermCodes.edo_id_is_summer?('2172')).to eq false
      expect(Berkeley::TermCodes.edo_id_is_summer?('2175')).to eq true
      expect(Berkeley::TermCodes.edo_id_is_summer?('2178')).to eq false
    end
  end

  it "should convert code and year into nice English" do
    Berkeley::TermCodes.to_english("2013", "B").should == "Spring 2013"
  end

  it "should throw an exception if bogus inputs are supplied" do
    expect{ Berkeley::TermCodes.to_english("1947", "Q")}.to raise_error(ArgumentError)
    expect{ Berkeley::TermCodes.to_code("Hiver")}.to raise_error(ArgumentError)
  end

  it "should convert a name into codes" do
    Berkeley::TermCodes.to_code("Spring").should == "B"
    Berkeley::TermCodes.to_code("Summer").should == "C"
    Berkeley::TermCodes.to_code("Fall").should == "D"
  end

  it 'should convert a friendly term into code and year' do
    term_hash = Berkeley::TermCodes.from_english('Fall 2013')
    term_hash[:term_yr].should == '2013'
    term_hash[:term_cd].should == 'D'
  end

  it 'should convert an unfriendly term into nothing' do
    Berkeley::TermCodes.from_english('Indefinitely').should be_nil
  end

  it 'converts a slug into code and year' do
    term_hash = Berkeley::TermCodes.from_slug('fall-2013')
    term_hash[:term_yr].should == '2013'
    term_hash[:term_cd].should == 'D'
  end

  it 'copes with the pre-1982 and/or non-Berkeley UC Winter quarter' do
    expect(Berkeley::TermCodes.to_slug('1974', 'A')).to eq 'winter-1974'
    expect(Berkeley::TermCodes.to_english('1974', 'A')).to eq 'Winter 1974'
  end

end
