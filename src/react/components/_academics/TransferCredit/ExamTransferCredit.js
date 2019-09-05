import React from 'react';
import PropTypes from 'prop-types';

import ExamRow from './ExamRow';

const sum = (acc, value) => acc + value;
const totalExamUnits = ({ apTestUnits, ibTestUnits, alevelTestUnits, otherCreditUnits }) => {
  return [apTestUnits, ibTestUnits, alevelTestUnits, otherCreditUnits].reduce(sum);
};

const propTypes = {
  summary: PropTypes.object
};

const ExamTransferCredit = (props) => {
  if (totalExamUnits(props.summary) > 0) {
    return (
      <div className="TransferCredit__table-container cc-table">
        <table className="cc-transfer-credits">
          <thead>
            <tr>
              <th>Exam/Other Credits</th>
              <th className="cc-table-right">Units</th>
            </tr>
          </thead>
          <tbody>
            <ExamRow name="Advanced Placement (AP)" value={props.summary.apTestUnits} />
            <ExamRow name="International Baccalaureate (IB)" value={props.summary.ibTestUnits} />
            <ExamRow name="GCE Advanced-Level (A-level)" value={props.summary.alevelTestUnits} />
            <ExamRow name="Other Credit" value={props.summary.otherCreditUnits} />

            <tr>
              <td className="cc-table-right">Total Exam Units:</td>
              <td className="cc-table-right">
                <strong>{totalExamUnits(props.summary).toFixed(3)}</strong>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    );
  } else {
    return null;
  }
};

ExamTransferCredit.propTypes = propTypes;

export default ExamTransferCredit;
