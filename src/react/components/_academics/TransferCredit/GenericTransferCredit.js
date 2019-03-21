import React from 'react';
import PropTypes from 'prop-types';

import TransferCreditTitle from './TransferCreditTitle';
import ExamTransferCredit from './ExamTransferCredit';

const propTypes = {
  detailed: PropTypes.array,
  summary: PropTypes.object,
  isStudent: PropTypes.bool,
  reportLink: PropTypes.object
};

const hasGradePoints = (details) => details && details.find(transfer => transfer.gradePoints);

const hasTestUnits = (props) => {
  if (props.summary && props.summary.careerDescr !== 'Undergraduate') {
    return false;
  }

  const { apTestUnits, ibTestUnits, alevelTestUnits } = props.summary;
  return [apTestUnits, ibTestUnits, alevelTestUnits].find(unitCount => unitCount > 0);
};

const GenericTransferCredit = (props) => {
  const showPointsColumn = hasGradePoints(props.detailed);
  const details = props.detailed || [];

  if (props.summary && (props.detailed || hasTestUnits(props))) {
    return (
      <div className="TransferCredit cc-transfer-credit-summary">
        <TransferCreditTitle
          description={props.summary.careerDescr}
          isStudent={props.isStudent}
          reportLink={props.reportLink}
        />

        <div className="TransferCredit__body">
          {details.length > 0 &&
            <div className="TransferCredit__table-container cc-table">
              <table className="cc-transfer-credits">
                <thead>
                  <tr>
                    <th>Institution</th>
                    <th className="cc-table-right">Units</th>
                    {showPointsColumn &&
                      <th className="cc-table-right">Points</th>
                    }
                  </tr>
                </thead>
                <tbody>
                  {details.map(transfer => (
                    <tr key={transfer.school}>
                      <td>{transfer.school}</td>
                      <td className="cc-table-right">{transfer.units.toFixed(3)}</td>
                      {showPointsColumn &&
                        <td className="cc-table-right">{transfer.gradePoints.toFixed(3)}</td>
                      }
                    </tr>
                  ))}

                  {props.summary &&
                    <tr>
                      <td className="cc-text-right">Totals:</td>
                      <td className="TranferCredit__unit-total">
                        {props.summary.totalTransferUnits.toFixed(3)}
                      </td>
                      {showPointsColumn &&
                        <td className="TranferCredit__unit-total">
                          {props.summary.totalTransferUnits.toFixed(3)}
                        </td>
                      }
                    </tr>
                  }
                </tbody>
              </table>
            </div>
          }
  
          <ExamTransferCredit summary={props.summary} />
        </div>
      </div>
    );
  } else {
    return null;
  }
};

GenericTransferCredit.propTypes = propTypes;

export default GenericTransferCredit;
