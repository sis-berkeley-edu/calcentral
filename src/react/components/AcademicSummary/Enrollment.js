import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import HubTermLegacyNote from './HubTermLegacyNote';
import TransferCredit from '../TransferCredit/TransferCredit';
import Semester from './Semester';
import SemestersSummary from './SemestersSummary';

const propTypes = {
  gpaUnits: PropTypes.object,
  semesters: PropTypes.array.isRequired,
  transferCredit: PropTypes.object.isRequired,
  user: PropTypes.object.isRequired,
  transferReportLink: PropTypes.object
};

const Enrollment = ({ gpaUnits, semesters, transferCredit, user, transferReportLink }) => {
  const showSemesters = !!(semesters.length && user.hasStudentHistory);
  const showSummary = !!(showSemesters && (user.roles.law || gpaUnits.totalLawUnits > 0));

  return (
    <Fragment>
      <h3 className="cc-enrollment-header">Enrollment</h3>

      {user.features.hubTermApi && <HubTermLegacyNote />}

      <TransferCredit
        semesters={semesters}
        isStudent={user.roles.student}
        reportLink={transferReportLink}
        {...transferCredit}
      />

      {showSemesters && semesters.reverse().map(semester => (
        <Semester
          key={semester.slug}
          canViewGrades={user.canViewGrades}
          transferCredit={transferCredit}
          {...semester}
        />
      ))}

      {showSummary &&
        <SemestersSummary
          semesters={semesters}
          totalLawUnits={gpaUnits.totalLawUnits}
          totalUnits={gpaUnits.totalUnits}
        />
      }
    </Fragment>
  );
};

Enrollment.propTypes = propTypes;

export default Enrollment;
