import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import './SemestersSummary.scss';

const propTypes = {
  semesters: PropTypes.array.isRequired,
  totalUnits: PropTypes.number,
  totalLawUnits: PropTypes.number,
  hasStudentHistory: PropTypes.bool
};

const SemestersSummary = ({ semesters, totalUnits, totalLawUnits, hasStudentHistory, hasLawRole }) => {
  const showSummary = semesters.length && hasStudentHistory && (hasLawRole || totalLawUnits > 0);

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
                  {totalUnits && <strong>{parseFloat(totalUnits).toFixed(1)}</strong>}
                </td>
                <td className="cc-table-right cc-academic-summary-table-units">
                  {totalLawUnits && <strong>{parseFloat(totalLawUnits).toFixed(1)}</strong>}
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
    }
  } = myStatus;

  const {
    gpaUnits: {
      totalUnits,
      totalLawUnits
    },
    semesters
  } = myAcademics;

  return {
    hasLawRole, hasStudentHistory, totalUnits, totalLawUnits, semesters
  };
};

export default connect(mapPropsToState)(SemestersSummary);
