import React, { useEffect } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import { fetchStatusAndHolds } from 'Redux/actions/statusActions';
import { fetchAdvisingStatusAndHolds } from 'Redux/actions/advisingStatusActions';

import TermRegistrationStatus from './TermRegistrationStatus';

const TermRegistrationStatuses = ({
  fetchStatusAndHolds,
  termRegistrations,
  advisingRegistrations,
  studentId,
  isAdvisor
}) => {
  useEffect(() => {
    fetchStatusAndHolds(studentId, isAdvisor);
  }, [studentId, isAdvisor]);

  const registrations = isAdvisor
    ? advisingRegistrations
    : termRegistrations;

  return (
    <div className="TermRegistrationStatuses" style={{ marginBottom: `15px` }}>
      {registrations.map(reg => (
        <TermRegistrationStatus
          key={reg.termId}
          termRegistration={reg}
        />
      ))}
    </div>
  );
};

TermRegistrationStatuses.propTypes = {
  fetchStatusAndHolds: PropTypes.func,
  termRegistrations: PropTypes.array,
  advisingRegistrations: PropTypes.array,
  studentId: PropTypes.string,
  isAdvisor: PropTypes.bool
};

const mapState = ({
  myStatusAndHolds,
  advising
}) => {
  const {
    termRegistrations = []
  } = myStatusAndHolds;

  const {
    userId: studentId,
    statusAndHolds: {
      termRegistrations: advisingRegistrations = [] 
    } = {}
  } = advising;

  return {
    termRegistrations,
    advisingRegistrations,
    studentId
  };
};

const mapDispatch = dispatch => {
  return {
    fetchStatusAndHolds: (studentId, isAdvisor) => {
      if (isAdvisor) {
        dispatch(fetchAdvisingStatusAndHolds(studentId));
      } else {
        dispatch(fetchStatusAndHolds());
      }
    }
  };
};

const ConnectedTermRegistrationStatuses = connect(mapState, mapDispatch)(TermRegistrationStatuses);

export default ConnectedTermRegistrationStatuses;
