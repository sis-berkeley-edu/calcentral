shared_examples 'a proxy that returns graduate milestone data' do

  it 'returns data with the expected structure' do
    expect(subject[:feed][:degreeProgress]).to be
    expect(subject[:feed][:degreeProgress].first[:acadCareer]).to be
    expect(subject[:feed][:degreeProgress].first[:acadPlan]).to be
    expect(subject[:feed][:degreeProgress].first[:acadProgCode]).to be
    expect(subject[:feed][:degreeProgress].first[:acadProg]).to be
    expect(subject[:feed][:degreeProgress].first[:requirements]).to be
  end

  it 'filters out any LAW career programs that are not LACAD' do
    expect(subject[:feed][:degreeProgress].length).to eql(4)
  end

  it 'filters out requirements that we don\'t want to display' do
    puts subject[:feed][:degreeProgress][0].pretty_inspect
    expect(subject[:feed][:degreeProgress][0][:requirements].length).to eql(2)
    expect(subject[:feed][:degreeProgress][1][:requirements].length).to eql(2)
  end

  it 'replaces codes with descriptive names' do
    expect(subject[:feed][:degreeProgress][0][:requirements][0][:name]).to eql('Advancement to Candidacy (Thesis Plan)')
    expect(subject[:feed][:degreeProgress][0][:requirements][0][:status]).to eql('Not Satisfied')
    expect(subject[:feed][:degreeProgress][1][:requirements][0][:name]).to eql('Advancement to Candidacy (Thesis Plan)')
    expect(subject[:feed][:degreeProgress][1][:requirements][0][:status]).to be nil
    expect(subject[:feed][:degreeProgress][1][:requirements][1][:name]).to eql('Advancement to Candidacy (Capstone Plan)')
    expect(subject[:feed][:degreeProgress][1][:requirements][0][:status]).to be nil
    expect(subject[:feed][:degreeProgress][2][:requirements][0][:name]).to eql('Approval for Qualifying Exam')
    expect(subject[:feed][:degreeProgress][2][:requirements][0][:status]).to eql('Completed')
  end

  it 'formats dates' do
    expect(subject[:feed][:degreeProgress][0][:requirements][0][:dateCompleted]).to eq ''
    expect(subject[:feed][:degreeProgress][1][:requirements][0][:dateCompleted]).to eq ''
    expect(subject[:feed][:degreeProgress][2][:requirements][0][:dateCompleted]).to eq 'Dec 22, 2016'
  end

  it 'attaches a notification if the milestone is incomplete and requires a form' do
    expect(subject[:feed][:degreeProgress][0][:requirements][0][:formNotification]).to eql('(Form Required)')
    expect(subject[:feed][:degreeProgress][1][:requirements][0][:formNotification]).to eql('(Form Required)')
    expect(subject[:feed][:degreeProgress][1][:requirements][1][:formNotification]).to be nil
    expect(subject[:feed][:degreeProgress][2][:requirements][0][:formNotification]).to be nil
  end

  it 'contains the expected Qualifying Exam milestone attempts data ordered with most recent first' do
    qualifying_exam_attempts = subject[:feed][:degreeProgress][2][:requirements][1][:attempts]
    expect(qualifying_exam_attempts.count).to eq 2
    expect(qualifying_exam_attempts[0][:sequenceNumber]).to eq 2
    expect(qualifying_exam_attempts[0][:date]).to eq 'Dec 22, 2016'
    expect(qualifying_exam_attempts[0][:result]).to eq 'Passed'
    expect(qualifying_exam_attempts[1][:sequenceNumber]).to eq 1
    expect(qualifying_exam_attempts[1][:date]).to eq 'Oct 01, 2016'
    expect(qualifying_exam_attempts[1][:result]).to eq 'Failed'
  end

  it 'builds a string to represent the milestone attempt' do
    qualifying_exam_attempts = subject[:feed][:degreeProgress][2][:requirements][1][:attempts]
    expect(qualifying_exam_attempts[0][:display]).to eq 'Passed Dec 22, 2016'
    expect(qualifying_exam_attempts[1][:display]).to eq 'Exam 1: Failed Oct 01, 2016'
  end

  context 'when the QE Results milestone is not satisfied' do
    it 'includes the proposed exam date on the QE Approval milestone' do
      qualifying_exam_approval_milestone = subject[:feed][:degreeProgress][3][:requirements][0]
      expect(qualifying_exam_approval_milestone[:proposedExamDate]).to eq 'Dec 21, 2016'
    end
    it 'does not include the proposed exam date on other milestones' do
      other_milestone = subject[:feed][:degreeProgress][0][:requirements][0]
      expect(other_milestone[:proposedExamDate]).not_to be
    end
  end

  context 'when the QE Results milestone is complete' do
    it 'does not include the proposed exam date on the QE Approval milestone' do
      qualifying_exam_approval_milestone = subject[:feed][:degreeProgress][2][:requirements][0]
      expect(qualifying_exam_approval_milestone[:proposedExamDate]).not_to be
    end
  end

end

shared_examples 'a proxy that returns undergraduate milestone data' do

  it_behaves_like 'a proxy that properly observes the undergrad degree progress for student feature flag'

  it 'returns data with the expected structure' do
    data = subject[:feed][:degreeProgress]
    expect(data).to be
    expect(data[:acadCareer]).to be

    plan_level_data = data[:progresses]
    expect(plan_level_data).to be
    expect(plan_level_data.first[:requirements]).to be
    expect(plan_level_data.first[:requirements].first[:name]).to be
    expect(plan_level_data.first[:requirements].first[:status]).to be
    expect(plan_level_data.first[:requirements].first[:code]).to be
  end

  it 'filters out requirements that we don\'t want to display' do
    plan_level_data = subject[:feed][:degreeProgress][:progresses]
    expect(plan_level_data.first[:requirements].length).to eql(4)
  end

  it 'sorts the requirements in the correct order' do
    plan_level_data = subject[:feed][:degreeProgress][:progresses]
    expect(plan_level_data.first[:requirements][0][:code]).to eql('000000001')
    expect(plan_level_data.first[:requirements][1][:code]).to eql('000000002')
    expect(plan_level_data.first[:requirements][2][:code]).to eql('000000018')
    expect(plan_level_data.first[:requirements][3][:code]).to eql('000000003')
  end

  it 'replaces codes with descriptive names' do
    plan_level_data = subject[:feed][:degreeProgress][:progresses]
    expect(plan_level_data.first[:requirements][0][:name]).to eq('Entry Level Writing')
    expect(plan_level_data.first[:requirements][0][:status]).to eq('Completed')
    expect(plan_level_data.first[:requirements][1][:name]).to eq('American History')
    expect(plan_level_data.first[:requirements][1][:status]).to eq('Incomplete')
    expect(plan_level_data.first[:requirements][2][:name]).to eq('American Institutions')
    expect(plan_level_data.first[:requirements][2][:status]).to eq('Incomplete')
    expect(plan_level_data.first[:requirements][3][:name]).to eq('American Cultures')
    expect(plan_level_data.first[:requirements][3][:status]).to eq('Completed')
  end
end
