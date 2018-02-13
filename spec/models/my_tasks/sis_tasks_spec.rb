describe MyTasks::SisTasks do
  let(:uid) { random_id }
  let(:starting_date) { DateTime.parse('20 Feb 2018 00:00:00 -0800') }
  subject { MyTasks::SisTasks.new(uid, starting_date) }

  context '#fetch_tasks' do
    let(:fetched_tasks) { subject.fetch_tasks }
    it 'returns formatted checklist items' do
      expect(fetched_tasks.count).to eq 27
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
end
