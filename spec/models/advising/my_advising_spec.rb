describe Advising::MyAdvising do
  let(:uid) { random_id }
  subject { described_class.new(uid).get_feed_internal }

  context 'fake proxies' do
    let(:fake_proxies) do
      proxies = {}
      [
        CampusSolutions::AdvisorStudentActionItems,
        CampusSolutions::AdvisorStudentAppointmentCalendar,
        CampusSolutions::AdvisorStudentRelationship,
        CampusSolutions::Link
      ].each do |proxy_class|
        fake_proxy = proxy_class.new(user_id: uid, fake: true)
        proxies[proxy_class] = fake_proxy
        allow(proxy_class).to receive(:new).and_return fake_proxy
      end
      proxies
    end

    let(:manage_appts_link) { 'https://bcs-web-dev-03.is.berkeley.edu:8443/psc/bcsdev/EMPLOYEE/HRMS/c/SCI_APPT_STUSS.SCI_APPT_MY_APPTS.GBL'}
    let(:new_appt_link) { 'https://bcs-web-dev-03.is.berkeley.edu:8443/psc/bcsdev/EMPLOYEE/HRMS/c/SCI_APPT_STUSS.SCI_APPT_SS_FLU.GBL'}

    before do
      fake_proxies[CampusSolutions::Link].set_response({
        status: 200,
        body: <<-XML
          <UC_LINK_RESOURCES>
            <Link>
              <PROPERTIES type="array"/>
              <URL_ID>UC_CX_APPOINTMENT_STD_MY_APPTS</URL_ID>
              <URL>#{manage_appts_link}</URL>
            </Link>
            <Link>
              <PROPERTIES type="array"/>
              <URL_ID>UC_CX_APPOINTMENT_STD_ADD</URL_ID>
              <URL>#{new_appt_link}</URL>
            </Link>
          </UC_LINK_RESOURCES>
        XML
      })
    end

    context 'well-behaved proxies' do
      it 'should return successful status code' do
        expect(subject[:statusCode]).to eq 200
      end
      it 'should include expected action items' do
        expect(subject[:feed][:actionItems].first).to include({
          actionItemDescription: 'Testing 123',
          actionItemStatus: 'Incomplete',
          actionItemTitle: 'Action Item test',
          actionItemView: 'Complete'
        })
      end
      it 'should include only incomplete action items' do
        expect(subject[:feed][:actionItems]).to have(10).items
        expect(subject[:feed][:actionItems].map { |item| item[:actionItemStatus] }).not_to include('Complete')
      end
      it 'should format dates' do
        expect(subject[:feed][:actionItems][0][:actionItemAssignedDate]).to eq({
          dateString: '7/22',
          dateTime: '2016-07-22T00:00:00-07:00',
          epoch: 1469170800
        })
        expect(subject[:feed][:actionItems][0][:actionItemDueDate]).to eq({
          dateString: '7/25',
          dateTime: '2016-07-25T00:00:00-07:00',
          epoch: 1469430000
        })
      end
      it 'should include expected advising appointments' do
        expect(subject[:feed][:appointments]).to have(23).items
        expect(subject[:feed][:appointments].first).to include({
          apptAdvisorId: '3030312345',
          apptAdvisorName: 'Jane Smith',
          apptCategory: 'Academic Advising',
          apptDate: '2016-07-25',
          apptDuration: '30',
          apptReason: 'Add',
          apptScheduledTime: '08.00.00.000000',
          apptStatus: 'CANCEL',
          apptType: 'Drop-in'
        })
      end
      it 'should include expected advisors' do
        expect(subject[:feed][:advisors]).to have(1).items
        expect(subject[:feed][:advisors].first).to include({
          assignedAdvisorEmail: 'janed@example.com',
          assignedAdvisorName: 'Jane Doe',
          assignedAdvisorProgram: 'Undergrad Chemistry',
          assignedAdvisorType: 'College Advisor'
        })
      end
      it 'should fetch links' do
        expect(subject[:feed][:links][:manageAppointments][:url]).to eq manage_appts_link
        expect(subject[:feed][:links][:newAppointment][:url]).to eq new_appt_link
      end
    end

    context 'graduate advisor relationships' do
      let(:graduate_advisor_relationships_xml) do
        <<-XML
          <UC_AA_STUDENT_ADVISOR>
            <STUDENT_ADVISOR type="array">
              <STUDENT_ADVISOR>
                <ASSIGNED_ADVISOR_TYPE_CODE>CHR</ASSIGNED_ADVISOR_TYPE_CODE>
                <ASSIGNED_ADVISOR_TYPE>Department Chair</ASSIGNED_ADVISOR_TYPE>
                <ASSIGNED_ADVISOR_PROGRAM>Electrical Eng &amp; Comp Sci MS</ASSIGNED_ADVISOR_PROGRAM>
                <ASSIGNED_ADVISOR_NAME>Dwight Schrute</ASSIGNED_ADVISOR_NAME>
                <ASSIGNED_ADVISOR_LOCATION/>
                <ASSIGNED_ADVISOR_EMAIL>dschrute@example.com</ASSIGNED_ADVISOR_EMAIL>
                <DEBUG>
                  <ASSIGNED_ADVISOR_ID>3030123456</ASSIGNED_ADVISOR_ID>
                </DEBUG>
              </STUDENT_ADVISOR>
              <STUDENT_ADVISOR>
                <ASSIGNED_ADVISOR_TYPE_CODE>GRAD</ASSIGNED_ADVISOR_TYPE_CODE>
                <ASSIGNED_ADVISOR_TYPE>Grad Div Representative</ASSIGNED_ADVISOR_TYPE>
                <ASSIGNED_ADVISOR_PROGRAM>Electrical Eng &amp; Comp Sci MS</ASSIGNED_ADVISOR_PROGRAM>
                <ASSIGNED_ADVISOR_NAME>Janet Levinson-Gould</ASSIGNED_ADVISOR_NAME>
                <ASSIGNED_ADVISOR_LOCATION/>
                <ASSIGNED_ADVISOR_EMAIL>jlgould@example.com</ASSIGNED_ADVISOR_EMAIL>
                <DEBUG>
                  <ASSIGNED_ADVISOR_ID>3030123457</ASSIGNED_ADVISOR_ID>
                </DEBUG>
              </STUDENT_ADVISOR>
              <STUDENT_ADVISOR>
                <ASSIGNED_ADVISOR_TYPE_CODE>GSAO</ASSIGNED_ADVISOR_TYPE_CODE>
                <ASSIGNED_ADVISOR_TYPE>Graduate Student Affairs Offcr</ASSIGNED_ADVISOR_TYPE>
                <ASSIGNED_ADVISOR_PROGRAM>Electrical Eng &amp; Comp Sci MS</ASSIGNED_ADVISOR_PROGRAM>
                <ASSIGNED_ADVISOR_NAME>Jason Miller</ASSIGNED_ADVISOR_NAME>
                <ASSIGNED_ADVISOR_LOCATION/>
                <ASSIGNED_ADVISOR_EMAIL>jcmiller@example.com</ASSIGNED_ADVISOR_EMAIL>
                <DEBUG>
                  <ASSIGNED_ADVISOR_ID>3030123458</ASSIGNED_ADVISOR_ID>
                </DEBUG>
              </STUDENT_ADVISOR>
              <STUDENT_ADVISOR>
                <ASSIGNED_ADVISOR_TYPE_CODE>GSAO</ASSIGNED_ADVISOR_TYPE_CODE>
                <ASSIGNED_ADVISOR_TYPE>Graduate Student Affairs Offcr</ASSIGNED_ADVISOR_TYPE>
                <ASSIGNED_ADVISOR_PROGRAM>Electrical Eng &amp; Comp Sci MS</ASSIGNED_ADVISOR_PROGRAM>
                <ASSIGNED_ADVISOR_NAME>Alan Parsons</ASSIGNED_ADVISOR_NAME>
                <ASSIGNED_ADVISOR_LOCATION/>
                <ASSIGNED_ADVISOR_EMAIL>aparsons@example.com</ASSIGNED_ADVISOR_EMAIL>
                <DEBUG>
                  <ASSIGNED_ADVISOR_ID>3030123459</ASSIGNED_ADVISOR_ID>
                </DEBUG>
              </STUDENT_ADVISOR>
              <STUDENT_ADVISOR>
                <ASSIGNED_ADVISOR_TYPE_CODE>GSI</ASSIGNED_ADVISOR_TYPE_CODE>
                <ASSIGNED_ADVISOR_TYPE>GSI Advisor</ASSIGNED_ADVISOR_TYPE>
                <ASSIGNED_ADVISOR_PROGRAM>Electrical Eng &amp; Comp Sci MS</ASSIGNED_ADVISOR_PROGRAM>
                <ASSIGNED_ADVISOR_NAME>Jim Halpert</ASSIGNED_ADVISOR_NAME>
                <ASSIGNED_ADVISOR_LOCATION/>
                <ASSIGNED_ADVISOR_EMAIL>jhalpert@example.com</ASSIGNED_ADVISOR_EMAIL>
                <DEBUG>
                  <ASSIGNED_ADVISOR_ID>3030123460</ASSIGNED_ADVISOR_ID>
                </DEBUG>
              </STUDENT_ADVISOR>
              <STUDENT_ADVISOR>
                <ASSIGNED_ADVISOR_TYPE_CODE>HGA</ASSIGNED_ADVISOR_TYPE_CODE>
                <ASSIGNED_ADVISOR_TYPE>Head Graduate Advisor</ASSIGNED_ADVISOR_TYPE>
                <ASSIGNED_ADVISOR_PROGRAM>Electrical Eng &amp; Comp Sci MS</ASSIGNED_ADVISOR_PROGRAM>
                <ASSIGNED_ADVISOR_NAME>Kelly Kapoor</ASSIGNED_ADVISOR_NAME>
                <ASSIGNED_ADVISOR_LOCATION/>
                <ASSIGNED_ADVISOR_EMAIL>kkapoor@example.com</ASSIGNED_ADVISOR_EMAIL>
                <DEBUG>
                  <ASSIGNED_ADVISOR_ID>3030123461</ASSIGNED_ADVISOR_ID>
                </DEBUG>
              </STUDENT_ADVISOR>
              <STUDENT_ADVISOR>
                <ASSIGNED_ADVISOR_TYPE_CODE>GEA</ASSIGNED_ADVISOR_TYPE_CODE>
                <ASSIGNED_ADVISOR_TYPE>Graduate Equity Advisor</ASSIGNED_ADVISOR_TYPE>
                <ASSIGNED_ADVISOR_PROGRAM>Electrical Eng &amp; Comp Sci MS</ASSIGNED_ADVISOR_PROGRAM>
                <ASSIGNED_ADVISOR_NAME>Oscar Martinez</ASSIGNED_ADVISOR_NAME>
                <ASSIGNED_ADVISOR_LOCATION/>
                <ASSIGNED_ADVISOR_EMAIL>oscar.m.martinez@example.com</ASSIGNED_ADVISOR_EMAIL>
                <DEBUG>
                  <ASSIGNED_ADVISOR_ID>3030123462</ASSIGNED_ADVISOR_ID>
                </DEBUG>
              </STUDENT_ADVISOR>
            </STUDENT_ADVISOR>
          </UC_AA_STUDENT_ADVISOR>
        XML
      end

      before do
        fake_proxies[CampusSolutions::AdvisorStudentRelationship].set_response({
          status: 200,
          body: graduate_advisor_relationships_xml
        })
      end

      it 'provides advisors in the expected order' do
        expect(subject[:feed][:advisors]).to have(7).items
        expect(subject[:feed][:advisors][0][:assignedAdvisorName]).to eq 'Jason Miller'
        expect(subject[:feed][:advisors][1][:assignedAdvisorName]).to eq 'Alan Parsons'
        expect(subject[:feed][:advisors][2][:assignedAdvisorName]).to eq 'Kelly Kapoor'
        expect(subject[:feed][:advisors][3][:assignedAdvisorName]).to eq 'Dwight Schrute'
        expect(subject[:feed][:advisors][4][:assignedAdvisorName]).to eq 'Oscar Martinez'
        expect(subject[:feed][:advisors][5][:assignedAdvisorName]).to eq 'Janet Levinson-Gould'
        expect(subject[:feed][:advisors][6][:assignedAdvisorName]).to eq 'Jim Halpert'
      end
    end

    context 'undergraduate advisor relationships' do
      let(:undergraduate_advisor_relationships_xml) do
        <<-XML
          <UC_AA_STUDENT_ADVISOR>
            <STUDENT_ADVISOR type="array">
              <STUDENT_ADVISOR>
                <ASSIGNED_ADVISOR_TYPE_CODE>MAJ</ASSIGNED_ADVISOR_TYPE_CODE>
                <ASSIGNED_ADVISOR_TYPE>Major Advisor</ASSIGNED_ADVISOR_TYPE>
                <ASSIGNED_ADVISOR_PROGRAM>Electrical Eng &amp; Comp Sci MS</ASSIGNED_ADVISOR_PROGRAM>
                <ASSIGNED_ADVISOR_NAME>Creed Braton</ASSIGNED_ADVISOR_NAME>
                <ASSIGNED_ADVISOR_LOCATION/>
                <ASSIGNED_ADVISOR_EMAIL>wcschneider@example.com</ASSIGNED_ADVISOR_EMAIL>
                <DEBUG>
                  <ASSIGNED_ADVISOR_ID>3030123463</ASSIGNED_ADVISOR_ID>
                </DEBUG>
              </STUDENT_ADVISOR>
              <STUDENT_ADVISOR>
                <ASSIGNED_ADVISOR_TYPE_CODE>UKNW</ASSIGNED_ADVISOR_TYPE_CODE>
                <ASSIGNED_ADVISOR_TYPE>Unknown Advisor Type</ASSIGNED_ADVISOR_TYPE>
                <ASSIGNED_ADVISOR_PROGRAM>Electrical Eng &amp; Comp Sci MS</ASSIGNED_ADVISOR_PROGRAM>
                <ASSIGNED_ADVISOR_NAME>Pam Beesly</ASSIGNED_ADVISOR_NAME>
                <ASSIGNED_ADVISOR_LOCATION/>
                <ASSIGNED_ADVISOR_EMAIL>dontcallmepammy@example.com</ASSIGNED_ADVISOR_EMAIL>
                <DEBUG>
                  <ASSIGNED_ADVISOR_ID>3030123462</ASSIGNED_ADVISOR_ID>
                </DEBUG>
              </STUDENT_ADVISOR>
              <STUDENT_ADVISOR>
                <ASSIGNED_ADVISOR_TYPE_CODE>MIN</ASSIGNED_ADVISOR_TYPE_CODE>
                <ASSIGNED_ADVISOR_TYPE>Minor Advisor</ASSIGNED_ADVISOR_TYPE>
                <ASSIGNED_ADVISOR_PROGRAM>Electrical Eng &amp; Comp Sci MS</ASSIGNED_ADVISOR_PROGRAM>
                <ASSIGNED_ADVISOR_NAME>Phyllis Vance</ASSIGNED_ADVISOR_NAME>
                <ASSIGNED_ADVISOR_LOCATION/>
                <ASSIGNED_ADVISOR_EMAIL>pvance@example.com</ASSIGNED_ADVISOR_EMAIL>
                <DEBUG>
                  <ASSIGNED_ADVISOR_ID>3030123464</ASSIGNED_ADVISOR_ID>
                </DEBUG>
              </STUDENT_ADVISOR>
              <STUDENT_ADVISOR>
                <ASSIGNED_ADVISOR_TYPE_CODE>COLL</ASSIGNED_ADVISOR_TYPE_CODE>
                <ASSIGNED_ADVISOR_TYPE>College Advisor</ASSIGNED_ADVISOR_TYPE>
                <ASSIGNED_ADVISOR_PROGRAM>Electrical Eng &amp; Comp Sci MS</ASSIGNED_ADVISOR_PROGRAM>
                <ASSIGNED_ADVISOR_NAME>Stanley Hudson</ASSIGNED_ADVISOR_NAME>
                <ASSIGNED_ADVISOR_LOCATION/>
                <ASSIGNED_ADVISOR_EMAIL>stanleyh@example.com</ASSIGNED_ADVISOR_EMAIL>
                <DEBUG>
                  <ASSIGNED_ADVISOR_ID>3030123465</ASSIGNED_ADVISOR_ID>
                </DEBUG>
              </STUDENT_ADVISOR>
            </STUDENT_ADVISOR>
          </UC_AA_STUDENT_ADVISOR>
        XML
      end

      before do
        fake_proxies[CampusSolutions::AdvisorStudentRelationship].set_response({
          status: 200,
          body: undergraduate_advisor_relationships_xml
        })
      end

      it 'provides advisors in the expected order' do
        expect(subject[:feed][:advisors]).to have(4).items
        expect(subject[:feed][:advisors][0][:assignedAdvisorName]).to eq 'Stanley Hudson'
        expect(subject[:feed][:advisors][1][:assignedAdvisorName]).to eq 'Creed Braton'
        expect(subject[:feed][:advisors][2][:assignedAdvisorName]).to eq 'Phyllis Vance'
        expect(subject[:feed][:advisors][3][:assignedAdvisorName]).to eq 'Pam Beesly'
      end
    end

    shared_examples 'a good and proper error report' do
      it 'reports error' do
        expect(Rails.logger).to receive(:error).with /Got errors in merged MyAdvising feed/
        expect(subject[:statusCode]).to eq 500
        expect(subject[:errored]).to eq true
      end
    end

    context 'proxy returns an error' do
      before do
        allow(fake_proxies[CampusSolutions::AdvisorStudentAppointmentCalendar]).to receive(:get).and_return(errored: true)
      end
      it_should_behave_like 'a good and proper error report'
    end

    context 'proxy fails to look up student ID' do
      before do
        allow(fake_proxies[CampusSolutions::AdvisorStudentActionItems]).to receive(:get).and_return(noStudentId: true)
      end
      it_should_behave_like 'a good and proper error report'
    end

    context 'missing links' do
      before do
        fake_proxies[CampusSolutions::Link].set_response({
          status: 200,
          body: <<-XML
            <UC_LINK_RESOURCES>
              <Link>
                <PROPERTIES type="array"/>
                <URL_ID>NOT_A_RELEVANT_ID</URL_ID>
                <URL>https://no.help.here</URL>
              </Link>
            </UC_LINK_RESOURCES>
          XML
        })
      end
      it 'returns nothing' do
        expect(subject[:feed][:links]).to eq nil
      end
    end
  end
end
