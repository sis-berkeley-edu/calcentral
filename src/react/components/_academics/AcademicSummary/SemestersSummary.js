import React from 'react';
import PropTypes from 'prop-types';

import './SemestersSummary.scss';

const propTypes = {
  semesters: PropTypes.array.isRequired,
  totalUnits: PropTypes.number,
  totalLawUnits: PropTypes.number
};

const SemestersSummary = (props) => (
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
              {props.totalUnits && <strong>{parseFloat(props.totalUnits).toFixed(1)}</strong>}
            </td>
            <td className="cc-table-right cc-academic-summary-table-units">
              {props.totalLawUnits && <strong>{parseFloat(props.totalLawUnits).toFixed(1)}</strong>}
            </td>
            <td></td>
            <td></td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
);

SemestersSummary.propTypes = propTypes;

export default SemestersSummary;
