import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

const propTypes = {
  errored: PropTypes.bool,
  isConcurrent: PropTypes.bool,
  isStudent: PropTypes.bool,
  isExStudent: PropTypes.bool,
  isApplicant: PropTypes.bool,
  isRegistered: PropTypes.bool,
  registrations: PropTypes.object,
  semesters: PropTypes.array,
  careers: PropTypes.array
};

const ConcurrentEnrollmentMessage = ({
  errored,
  isConcurrent, isStudent, isExStudent, isApplicant, isRegistered,
  registrations, semesters, careers
}) => {
  const hasRegistrations = Object.getOwnPropertyNames(registrations).length !== 0;
  const hasAcademicInfo = hasRegistrations || semesters.length > 0;

  const showProfileMessage = (!hasAcademicInfo || careers.length === 0);

  if (errored || !showProfileMessage) {
    return null;
  }

  if (isConcurrent) {
    return (
      <Fragment>
        <div className="cc-widget-profile-message-text">
          You are a concurrent enrollment student.
        </div>
        <ul className="cc-list-bullets">
          <li>If you are a UC Extension student, more information is available at <a href="http://extension.berkeley.edu/static/studentservices/concurrent/">UC Berkeley Extension</a>.</li>
          <li>If you are an EAP student, more information is available at the <a href="http://internationaloffice.berkeley.edu/students/exchange/main">Berkeley International Office</a>.</li>
        </ul>
      </Fragment>
    );
  } else if (!isStudent && isExStudent) {
    return (
      <Fragment>
        <h3>Standing</h3>
        <div className="cc-widget-profile-message-text">
          You are not currently considered an active student. If you are seeking information on your conferred degree,
          we are in the process of updating this functionality.  In the meantime, please monitor your bMail for a
          message regarding your completed degree.
        </div>
      </Fragment>
    );
  } else if ((isStudent || isApplicant) && !hasAcademicInfo) {
    return (
      <div className="cc-academics-nocontent-container">
        <div className="cc-widget-profile-message-text">
          { isRegistered
            ? <span>More information will display here when available.</span>
            : <span>More information will display here when your academic status changes.</span>
          }
          Check back for:
        </div>
        <ul className="cc-list-bullets">
          <li>Class enrollments, including waitlist information.</li>
          <li>Your academic status, including standing, GPA, units, major, college, and more.</li>
          <li>Your registration status, including any holds limiting your access to campus services.</li>
          <li>Course information, including class and exam schedules, class locations, textbooks, and recordings.</li>
        </ul>
      </div>
    );
  } else {
    return null;
  }
};

ConcurrentEnrollmentMessage.propTypes = propTypes;

const mapStateToProps = ({
  myAcademics: {
    collegeAndLevel: {
      errored,
      careers
    } = {},
    semesters
  } = {},
  myStatus: {
    roles: {
      concurrentEnrollmentStudent: isConcurrent,
      student: isStudent,
      exStudent: isExStudent,
      applicant: isApplicant,
      registered: isRegistered
    } = {}
  } = {},
  myRegistrations: {
    registrations = {}
  } = {}
}) => ({
  errored,
  isConcurrent, isStudent, isExStudent, isApplicant, isRegistered,
  registrations,
  semesters: semesters || [],
  careers: careers || []
});

export default connect(mapStateToProps)(ConcurrentEnrollmentMessage);
