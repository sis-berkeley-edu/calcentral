import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { Provider, connect } from 'react-redux';
import { react2angular } from 'react2angular';

import store from 'Redux/store';
import { fetchAppointments } from 'Redux/actions/advisingActions';

import Spinner from 'React/components/Spinner';
import AppointmentsTable from './AppointmentsTable';
import InstructingAppointments from './InstructingAppointments';

import './EmploymentAppointments.scss';

// TODO: Remove this when core-js is upgraded to v3
// flatMap is required for IE and current Edge (18)
import 'core-js/fn/array/flat-map';

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

// Returns the classes for a semester, formatted
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

const propTypes = {
  dispatch: PropTypes.func,
  userId: PropTypes.string.isRequired,
  academicsLoaded: PropTypes.bool,
  appointmentsLoaded: PropTypes.bool,
  appointments: PropTypes.array.isRequired,
  teachingSemesters: PropTypes.array.isRequired,
  termsTaught: PropTypes.number,
  appointmentLink: PropTypes.object,
  featureEnabled: PropTypes.bool
};

const EmploymentAppointments = ({
  dispatch,
  userId,
  academicsLoaded,
  appointmentsLoaded,
  appointments,
  teachingSemesters,
  termsTaught,
  appointmentLink,
  featureEnabled
}) => {
  if (!featureEnabled) {
    return null;
  }

  useEffect(() => {
    dispatch(fetchAppointments(userId));
  }, [userId]);

  const [showAll, setShowAll] = useState(false);
  const classes = (teachingSemesters).flatMap(semesterClasses).filter(klass => klass.role === 'Instructor');
  const hasPreviousClasses = classes.find(klass => klass.timeBucket === 'past') !== undefined;
  const hasCurrentClasses = classes.find(klass => klass.timeBucket !== 'past') !== undefined;
  const shouldRender = (termsTaught > 0 || classes.length > 0 || appointments.length > 0);
  const showFirst = 10;

  if (academicsLoaded && appointmentsLoaded) {
    if (shouldRender) {
      return (
        <div className='EmploymentAppointments'>
          <header>
            <h2>Employment Appointments</h2>
          </header>
          <div className='EmploymentAppointments--body'>
            <p>
              Use <APILink {...appointmentLink} /> to view &quot;Appointment History&quot;
              or &quot;Appointment Eligibility&quot; report.
            </p>

            { termsTaught > 0 &&
              <p>
                <strong>{termsTaught}</strong> Terms Teaching
                (past, current, and future)
              </p>
            }

            <h3>Appointments <span>(current and future)</span></h3>
            <AppointmentsTable appointments={appointments} showAll={showAll} showFirst={showFirst} />

            {appointments.length > showFirst && !showAll &&
              <div className="ButtonContainer">
                <button className="cc-button" onClick={() => setShowAll(!showAll)}>
                  Show All Appointments
                </button>
              </div>
            }

            <InstructingAppointments classes={classes}
              hasCurrentClasses={hasCurrentClasses}
              hasPreviousClasses={hasPreviousClasses}
            />
          </div>
        </div>
      );
    } else {
      return null;
    }
  } else {
    return <Spinner />;
  }
};

EmploymentAppointments.propTypes = propTypes;

const mapStateToProps = ({ advising = {}, myStatus = {} }) => {
  const {
    userId,
    academics: {
      loaded: academicsLoaded,
      teachingSemesters
    } = {},
    appointments: {
      loaded: appointmentsLoaded,
      appointments,
      termsTaught,
      link: appointmentLink
    } = {}
  } = advising;

  const {
    features: {
      employmentAppointments
    } = {}
  } = myStatus;

  return {
    userId, academicsLoaded, appointmentsLoaded,
    appointments: (appointments || []),
    teachingSemesters: (teachingSemesters || []),
    termsTaught,
    appointmentLink,
    featureEnabled: employmentAppointments
  };
};

const ConnectedAppointments = connect(mapStateToProps)(EmploymentAppointments);

const EmploymentAppointmentsContainer = () => (
  <Provider store={store}>
    <ConnectedAppointments />
  </Provider>
);

angular.module('calcentral.react').component('employmentAppointments', react2angular(EmploymentAppointmentsContainer));
