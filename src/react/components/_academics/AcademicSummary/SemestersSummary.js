import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import './SemestersSummary.scss';

const propTypes = {
  semesters: PropTypes.array.isRequired,
  totalUnits: PropTypes.number,
  totalLawUnits: PropTypes.number,
  hasStudentHistory: PropTypes.bool,
  hasLawJointDegree: PropTypes.bool,
  totalPreviousCareerCumUnits: PropTypes.number,
  totalPreviousCareerLawUnits: PropTypes.number
};

const SemestersSummary = ({ semesters, totalUnits, totalLawUnits, hasStudentHistory, hasLawRole,
                            hasLawJointDegree, totalPreviousCareerCumUnits, totalPreviousCareerLawUnits }) => {
  const showSummary = semesters.length && hasStudentHistory && (hasLawRole || totalLawUnits > 0 || hasLawJointDegree);

  let summaryTotalLawUnits = totalLawUnits;
  let summaryTotalUnits = totalUnits;
  if (hasLawJointDegree) {
    summaryTotalLawUnits = totalLawUnits + totalPreviousCareerLawUnits;
    summaryTotalUnits = totalUnits + totalPreviousCareerCumUnits;
  }

  if (showSummary) {
    return (
      <div className="SemestersSummary">
        <div className="cc-table">
          <table className="cc-class-enrollments">
            <caption>
              <h4>Summary</h4>
            </caption>
            <thead>
              <tr>
                <th></th>
                <th></th>
                <th className="cc-table-right cc-academic-summary-table-units">Un.</th>
                <th className="cc-table-right cc-academic-summary-table-units">Law Un.</th>
                <th></th>
                <th></th>
              </tr>
            </thead>
            <tfoot>
              <tr>
                <td colSpan="2" scope="row" className="cc-table-right cc-academic-summary-table-units">
                  Earned Total:
                </td>
                <td className="cc-table-right cc-academic-summary-table-units">
                  {summaryTotalUnits && <strong>{parseFloat(summaryTotalUnits).toFixed(1)}</strong>}
                </td>
                <td className="cc-table-right cc-academic-summary-table-units">
                  {summaryTotalLawUnits && <strong>{parseFloat(summaryTotalLawUnits).toFixed(1)}</strong>}
                </td>
                <td></td>
                <td></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    );
  } else {
    return null;
  }
};

SemestersSummary.propTypes = propTypes;

const mapPropsToState = ({ myAcademics, myStatus }) => {
  const {
    hasStudentHistory,
    roles: {
      law: hasLawRole
    },
    academicRoles: {
      current: {
        lawJointDegree: hasLawJointDegree
      }
    }
  } = myStatus;

  const {
    gpaUnits: {
      totalUnits,
      totalLawUnits,
      totalPreviousCareerCumUnits,
      totalPreviousCareerLawUnits
    },
    semesters
  } = myAcademics;

  return {
    hasLawRole, hasStudentHistory, totalUnits, totalLawUnits, semesters, hasLawJointDegree,
    totalPreviousCareerCumUnits, totalPreviousCareerLawUnits
  };
};

export default connect(mapPropsToState)(SemestersSummary);
