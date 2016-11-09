# encoding: UTF-8

shared_examples 'a newly initialized mailing list' do
  let(:list) { described_class.new(canvas_site_id: canvas_site_id) }

  it 'is valid' do
    expect(response).not_to include 'errorMessages'
  end

  it 'returns Canvas site data' do
    expect(response['canvasSite']['canvasCourseId']).to eq fake_course_data['id'].to_s
    expect(response['canvasSite']['url']).to include fake_course_data['id'].to_s
    expect(response['canvasSite']['courseCode']).to eq fake_course_data['course_code']
    expect(response['canvasSite']['sisCourseId']).to eq fake_course_data['sis_course_id']
    expect(response['canvasSite']['name']).to eq fake_course_data['name']
  end

  it 'initializes as unregistered' do
    expect(response['mailingList']['state']).to eq 'unregistered'
    expect(response['mailingList']['domain']).to eq list_domain
    expect(response['mailingList']).not_to include('creationUrl')
    expect(response['mailingList']).not_to include('timeLastPopulated')
  end

  it 'returns error on attempt to populate before save' do
    list.populate
    expect(response['errorMessages']).to include("Mailing list \"#{list.list_name}\" must be created before being populated.")
    expect(response['mailingList']).not_to include('timeLastPopulated')
  end

  describe 'normalizing list names' do
    it 'normalizes caps and spaces' do
      fake_course_data['name'] = 'CHEM 1A LEC 003'
      expect(response['mailingList']['name']).to eq 'chem-1a-lec-003-fa13'
    end

    it 'normalizes punctuation' do
      fake_course_data['name'] = 'The "Wild"-"Wild" West?'
      expect(response['mailingList']['name']).to eq 'the-wild-wild-west-fa13'
    end

    it 'removes invalid leading and trailing characters' do
      fake_course_data['name'] = '{{design}}'
      expect(response['mailingList']['name']).to eq 'design-fa13'
    end

    it 'normalizes diacritics' do
      fake_course_data['name'] = 'Conversation intermédiaire'
      expect(response['mailingList']['name']).to eq 'conversation-intermediaire-fa13'
    end
  end

  context 'nonexistent Canvas site' do
    before { allow_any_instance_of(Canvas::Course).to receive(:course).and_return(statusCode: 404, error: [{message: 'The specified resource was not found.'}]) }

    it 'returns error data' do
      expect(response).not_to include :mailingList
      expect(response['errorMessages']).to include("No bCourses site with ID \"#{canvas_site_id}\" was found.")
    end
  end
end

shared_examples 'mailing list creation errors' do

  context 'invalid list name' do
    let(:create_list) { described_class.create(canvas_site_id: canvas_site_id, list_name: '$crooge McDuck and the 1%') }

    it 'does not create a list with an invalid name' do
      count = described_class.count
      create_list
      expect(described_class.count).to eq count
      expect(response['errorMessages']).to include('List name may contain only lowercase, numeric, underscore and hyphen characters.')
    end
  end

  context 'list name already exists in database' do
    let(:list_name) { random_string(15) }
    let(:create_list) { described_class.create(canvas_site_id: canvas_site_id, list_name: list_name) }
    before { described_class.create(canvas_site_id: random_id, list_name: list_name)  }

    it 'does not create list and returns error' do
      count = described_class.count
      create_list
      expect(described_class.count).to eq count
      expect(response['errorMessages']).to include("List name \"#{list_name}\" has already been reserved.")
    end
  end

  context 'course id already exists in database' do
    before { described_class.create(canvas_site_id: canvas_site_id)  }

    it 'does not create new record and returns error' do
      count = described_class.count
      create_list
      expect(described_class.count).to eq count
      expect(response['errorMessages']).to include("Canvas site ID \"#{canvas_site_id}\" has already reserved a mailing list.")
    end
  end
end
