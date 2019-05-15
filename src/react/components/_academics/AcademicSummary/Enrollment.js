import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import HubTermLegacyNote from './HubTermLegacyNote';
import TransferCredit from '../TransferCredit/TransferCredit';
import Semesters from './Semesters';
import SemestersSummary from './SemestersSummary';

const propTypes = {
  gpaUnits: PropTypes.object,
  semesters: PropTypes.array.isRequired
};

const Enrollment = ({
  semesters,
  transferCredit,
  hasStudentHistory
}) => {
  const showTransferCredit = transferCredit.law.detailed || transferCredit.graduate.detailed || transferCredit.undergraduate.detailed;
  const showEnrollment = (semesters.length > 0 && hasStudentHistory) || showTransferCredit;

  if (showEnrollment) {
    return (
      <Fragment>
        <h3 className="cc-enrollment-header">Enrollment</h3>
        <HubTermLegacyNote />
        <TransferCredit />
        <Semesters />
        <SemestersSummary />
      </Fragment>
    );
  } else {
    return null;
  }
};

Enrollment.propTypes = propTypes;

const mapStateToProps = ({
  myAcademics: { semesters },
  myStatus: { hasStudentHistory },
  myTransferCredit: transferCredit
}) => ({
  hasStudentHistory,
  semesters,
  transferCredit
});

export default connect(mapStateToProps)(Enrollment);
