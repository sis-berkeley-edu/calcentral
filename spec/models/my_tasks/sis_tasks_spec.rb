describe MyTasks::SisTasks do
  let(:uid) { random_id }
  let(:starting_date) { DateTime.parse('20 Feb 2018 00:00:00 -0800') }
  subject { MyTasks::SisTasks.new(uid, starting_date) }

  context '#fetch_tasks' do
    let(:fetched_tasks) { subject.fetch_tasks }
    it 'returns formatted checklist items' do
      expect(fetched_tasks.count).to eq 28
      fetched_tasks.each do |checklist_item|
        expect(checklist_item[:emitter]).to eq 'Campus Solutions'
      end
    end

    it 'includes cs responsible contact email address' do
      fetched_tasks.each do |checklist_item|
        expect(checklist_item[:cs]).to have_key(:responsibleContactEmail)
      end
      expect(fetched_tasks[0][:cs][:responsibleContactEmail]).to eq 'BCS@BERKELEY.EDU'
      expect(fetched_tasks[1][:cs][:responsibleContactEmail]).to eq nil
      expect(fetched_tasks[2][:cs][:responsibleContactEmail]).to eq 'BCS@BERKELEY.EDU'
      expect(fetched_tasks[3][:cs][:responsibleContactEmail]).to eq 'BCS@BERKELEY.EDU'
    end

    it 'includes cs organization' do
      fetched_tasks.each do |checklist_item|
        expect(checklist_item[:cs]).to have_key(:organization)
      end
      expect(fetched_tasks[4][:cs][:organization]).to eq 'Hotchkiss School The'
    end

    it 'includes cs shown status' do
      fetched_tasks.each do |checklist_item|
        expect(checklist_item[:cs]).to have_key(:showStatus)
      end
    end

    it 'includes cs checklist item status code' do
      fetched_tasks.each do |checklist_item|
        expect(checklist_item[:cs]).to have_key(:itemStatusCode)
      end
      expect(fetched_tasks[0][:cs][:itemStatusCode]).to eq 'I'
      expect(fetched_tasks[1][:cs][:itemStatusCode]).to eq 'I'
      expect(fetched_tasks[2][:cs][:itemStatusCode]).to eq 'I'
      expect(fetched_tasks[3][:cs][:itemStatusCode]).to eq 'C'
    end

    it 'maps item status code to display status code' do
      fetched_tasks.each do |checklist_item|
        expect(checklist_item[:cs]).to have_key(:displayStatus)
      end
      expect(fetched_tasks[0][:cs][:displayStatus]).to eq 'incomplete'
      expect(fetched_tasks[1][:cs][:displayStatus]).to eq 'incomplete'
      expect(fetched_tasks[2][:cs][:displayStatus]).to eq 'incomplete'
      expect(fetched_tasks[3][:cs][:displayStatus]).to eq 'completed'
      expect(fetched_tasks[26][:cs][:displayStatus]).to eq 'beingProcessed'
      expect(fetched_tasks[22][:cs][:displayStatus]).to eq 'furtherActionNeeded'
    end

    it 'maps admin function code and checklist item code to display category' do
      fetched_tasks.each_with_index do |checklist_item, index|
        expect(checklist_item[:cs]).to have_key(:displayCategory)
      end
      expect(fetched_tasks[0][:cs][:displayCategory]).to eq 'newStudent'
      expect(fetched_tasks[1][:cs][:displayCategory]).to eq 'finaid'
      expect(fetched_tasks[2][:cs][:displayCategory]).to eq 'student'
      expect(fetched_tasks[11][:cs][:displayCategory]).to eq 'admission'
      expect(fetched_tasks[21][:cs][:displayCategory]).to eq 'residency'
    end
  end

  context '#display_status' do
    it 'converts checklist item status codes to display statuses' do
      expect(subject.instance_eval { display_status('I') }).to eq 'incomplete'
      expect(subject.instance_eval { display_status('Z') }).to eq 'furtherActionNeeded'
      expect(subject.instance_eval { display_status('A') }).to eq 'beingProcessed'
      expect(subject.instance_eval { display_status('R') }).to eq 'beingProcessed'
      expect(subject.instance_eval { display_status('C') }).to eq 'completed'
      expect(subject.instance_eval { display_status('W') }).to eq 'completed'
    end
    it 'defaults to incomplete status when status code is unknown' do
      expect(subject.instance_eval { display_status('B') }).to eq 'incomplete'
    end
  end

  context '#display_category' do
    it 'returns residency category when checklist item code begins with \'RR\'' do
      expect(subject.instance_eval { display_category('STRM','RR54AF')}).to eq 'residency'
      expect(subject.instance_eval { display_category('ADMA','RRSLRA')}).to eq 'residency'
      expect(subject.instance_eval { display_category('SPRG','RRPPCP')}).to eq 'residency'
      expect(subject.instance_eval { display_category('SPRG','RR54HS')}).to eq 'residency'
      expect(subject.instance_eval { display_category('STRM','RRWUPP')}).to eq 'residency'
    end
    it 'returns admission category when admin function code is \'ADMP\'' do
      expect(subject.instance_eval { display_category('ADMP', 'ACTSAT')}).to eq 'admission'
    end
    it 'returns financial aid category when admin function code is \'FINA\'' do
      expect(subject.instance_eval { display_category('FINA', 'FAPFDB')}).to eq 'finaid'
    end
    it 'returns student category when admin function code is \'GEN\'' do
      expect(subject.instance_eval { display_category('GEN', 'A10000')}).to eq 'student'
    end
    it 'returns student category when admin function code is \'SPRG\'' do
      expect(subject.instance_eval { display_category('SPRG', 'IGNIF')}).to eq 'student'
    end
    it 'returns student category when admin function code is \'STRM\'' do
      expect(subject.instance_eval { display_category('STRM', 'IGNIF')}).to eq 'student'
    end
    it 'returns new student category when admin function code is \'ADMA\'' do
      expect(subject.instance_eval { display_category('ADMA', 'AL0001')}).to eq 'newStudent'
    end
    it 'returns student category when admin function code is unknown' do
      expect(subject.instance_eval { display_category('ABCD', 'EFGH')}).to eq 'student'
    end
  end
end
