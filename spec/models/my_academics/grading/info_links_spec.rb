describe MyAcademics::Grading::InfoLinks do
  let(:campus_links) do
    {
      'links' => campus_links_links,
      'navigation' => []
    }
  end
  let(:campus_links_links) do
    [
      {
        "name"=>"511.org (Bay Area Transportation Planner)",
        "description"=>"Calculates transportation options for traveling",
        "url"=>"http://www.511.org/",
        "roles"=>{"student"=>true, "applicant"=>true, "staff"=>true, "faculty"=>true, "exStudent"=>true, "summerVisitor"=>true},
        "categories"=>[{"topcategory"=>"Getting Around", "subcategory"=>"Parking & Transportation"}]
      },
      {
        "name"=>"Assistance with Grading: General",
        "description"=>"Assistance with grading for general classes",
        "url"=>"http://registrar.berkeley.edu/faculty-staff/grading/final-term-grades",
        "roles"=>{"student"=>false, "applicant"=>false, "staff"=>false, "faculty"=>true, "exStudent"=>false, "summerVisitor"=>false},
        "categories"=>[{"topcategory"=>"Faculty", "subcategory"=>"Grading"}]
      },
      {
        "name"=>"Assistance with Grading: Law",
        "description"=>"Assistance with grading for Law classes",
        "url"=>"https://www.law.berkeley.edu/administration/registrar/egrades/",
        "roles"=>{"student"=>false, "applicant"=>false, "staff"=>false, "faculty"=>true, "exStudent"=>false, "summerVisitor"=>false},
        "categories"=>[{"topcategory"=>"Faculty", "subcategory"=>"Grading"}]
      },
      {
        "name"=>"Assistance with Midpoint Grading: General",
        "description"=>"Assistance with midpoint grading for general classes",
        "url"=>"http://registrar.berkeley.edu/faculty-staff/grading/midterm-deficient-grades",
        "roles"=>{"student"=>false, "applicant"=>false, "staff"=>false, "faculty"=>true, "exStudent"=>false, "summerVisitor"=>false},
        "categories"=>[{"topcategory"=>"Faculty", "subcategory"=>"Grading"}]
      },
      {
        "name"=>"Academic Calendar - Berkeley Law",
        "description"=>"Academic calendar including academic and administrative holidays",
        "url"=>"https://www.law.berkeley.edu/php-programs/courses/academic_calendars.php",
        "roles"=>{"student"=>true, "applicant"=>true, "staff"=>true, "faculty"=>true, "exStudent"=>true, "summerVisitor"=>true},
        "categories"=>[{"topcategory"=>"Academic Planning", "subcategory"=>"Calendar"}]
      }
    ]
  end

  before do
    my_campus_links_stub = double(:links_my_campus_links, get_feed: campus_links)
    allow(Links::MyCampusLinks).to receive(:new).and_return(my_campus_links_stub)
  end

  describe '.fetch' do
    it 'returns faculty grading info links' do
      grading_info_links = described_class.fetch
      expect(grading_info_links[:general]['url']).to eq 'http://registrar.berkeley.edu/faculty-staff/grading/final-term-grades'
      expect(grading_info_links[:midterm]['url']).to eq 'http://registrar.berkeley.edu/faculty-staff/grading/midterm-deficient-grades'
      expect(grading_info_links[:law]['url']).to eq 'https://www.law.berkeley.edu/administration/registrar/egrades/'
    end
  end
end
