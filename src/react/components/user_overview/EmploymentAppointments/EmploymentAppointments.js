import React from 'react';
import PropTypes from 'prop-types';
import { react2angular } from 'react2angular';
import WidgetHeader from '../../Widget/WidgetHeader';
import AppointmentRow from './AppointmentRow';
import InstructingAppointments from './InstructingAppointments';

const APILink = (props) => {
  if (props.showNewWindow) {
    return <a href={props.url} target="_top">{props.name}</a>;
  } else {
    return <a href={props.url}>{props.name}</a>;
  }
};

APILink.propTypes = {
  name: PropTypes.string.isRequired,
  url: PropTypes.string.isRequired
};

const propTypes = {
  user: PropTypes.object.isRequired,
  teachingSemesters: PropTypes.array
};

const processAcademics = function(teachingSemesters) {
  const semesterClasses = (semester) => {
    return semester.classes.map(formatSemesterData(semester));
  };

  const formatSemesterData = (semester) => {
    return (klass) => {
      klass.semester = semester;

      return {
        title: klass.title,
        role: klass.role,
        semesterName: semester.name,
        timeBucket: semester.timeBucket
      };
    };
  };

  return new Promise((resolve) => {
    const classes = (teachingSemesters || []).flatMap(semesterClasses).filter(klass => klass.role === 'Instructor');
    const hasPreviousClasses = classes.find(klass => klass.timeBucket === 'past') !== undefined;
    const hasCurrentClasses = classes.find(klass => klass.timeBucket !== 'past') !== undefined;
    resolve({ classes, hasPreviousClasses, hasCurrentClasses });
  });
};

const fetchAppointments = function(studentId) {
  return new Promise((resolve) => {
    fetch(`/api/advising/employment_appointments/${studentId}`).then(response => response.json()).then(json => resolve(json));
  });
};

class EmploymentAppointments extends React.Component {
  constructor(props) {
    super(props);

    const loadAppointments = fetchAppointments(props.user.ldapUid).then(data => this.setState(data));
    const loadAcademics = processAcademics(props.teachingSemesters).then(data => {
      this.setState(data);
    });

    this.state = {
      appointments: [],
      classes: [],
      termsTaught: 0,
      hasCurrentClasses: false,
      hasPreviousClasses: false
    };

    Promise.all([loadAppointments, loadAcademics]).finally(() => this.setState({ ready: true }));
  }

  shouldRender() {
    return this.state.termsTaught > 0 || this.state.classes.length || this.state.appointments.length;
  }

  render() {
    if (this.state.ready && this.shouldRender()) {
      return (
        <div className="cc-widget EmploymentAppointments">
          <WidgetHeader title="Employment Appointments" />
          <div className="cc-widget-padding">
            <p>
              Use <APILink {...this.state.link} /> to view &quot;Appointment History&quot;
              or &quot;Appointment Eligibility&quot; report.
            </p>

            { this.state.termsTaught > 0 &&
              <p>
                <strong>{this.state.termsTaught}</strong> Terms Teaching
                (past, current, and future)
              </p>
            }
  
            <h3>Appointments <span>(current and future)</span></h3>
  
            { this.state.appointments.length 
              ? (
                <div className="apppointments">
                  { this.state.appointments.map((appointment, index) => {
                    return (
                      <AppointmentRow 
                        key={index}
                        jobCode={appointment.job_code}
                        startDate={appointment.start_date}
                        endDate={appointment.end_date}
                        distributionPercentage={appointment.distribution_percentage}
                        {...appointment}>
                      </AppointmentRow>
                    );
                  })
                  }
                </div>
              )
              : <p>No current or future appointments.</p>
            }
  
            <InstructingAppointments classes={this.state.classes}
              hasCurrentClasses={this.state.hasCurrentClasses}
              hasPreviousClasses={this.state.hasPreviousClasses}
            />
          </div>
        </div>
      );
    } else {
      return null;
    }
  }
}
EmploymentAppointments.propTypes = propTypes;

angular.module('calcentral.react').component('employmentAppointments', react2angular(EmploymentAppointments));

export default EmploymentAppointments;
