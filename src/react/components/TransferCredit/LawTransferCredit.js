import React from 'react';
import PropTypes from 'prop-types';

import TransferCreditTitle from './TransferCreditTitle';

const propTypes = {
  detailed: PropTypes.array,
  summary: PropTypes.object,
  semesters: PropTypes.array,
  isStudent: PropTypes.bool,
  reportLink: PropTypes.object
};

const LawTransferCredit = (props) => {
  const byTermDescending = (a, b) => a.termId >= b.termId ? -1 : 1;

  if (props.detailed && props.summary) {
    return (
      <div className="TransferCredit cc-transfer-credit-summary">
        <TransferCreditTitle
          description={props.summary.careerDescr}
          isStudent={props.isStudent}
          reportLink={props.reportLink}
        />

        <div className="cc-table">
          {props.detailed.length > 0 &&
            <table className="cc-transfer-credits">
              <thead>
                <tr>
                  <th>Institution</th>
                  <th className="cc-table-right">Units</th>
                  <th className="cc-table-right">Law Units</th>
                </tr>
              </thead>
              <tbody>
                {props.detailed.sort(byTermDescending).map((transfer, index) => (
                  <tr key={index}>
                    <td>
                      {transfer.school}

                      {transfer.requirementDesignation &&
                        <div className="cc-requirements-designation">
                          {transfer.requirementDesignation}
                        </div>
                      }

                      <div className="cc-transfer-credit-summary__semester-posted">
                        Posted {transfer.termDescription}
                      </div>
                    </td>
                    <td className="TranferCredit__unit-count">{transfer.units.toFixed(3)}</td>
                    <td className="TranferCredit__unit-count">{transfer.lawUnits.toFixed(3)}</td>
                  </tr>
                ))}

                {props.summary &&
                  <tr>
                    <td className="cc-text-right">Totals:</td>
                    <td className="TranferCredit__unit-total">
                      {props.summary.totalTransferUnits.toFixed(3)}
                    </td>
                    <td className="TranferCredit__unit-total">
                      {props.summary.totalTransferUnitsLaw.toFixed(3)}
                    </td>
                  </tr>
                }
              </tbody>
            </table>
          }
        </div>
      </div>
    );
  } else {
    return null;
  }
};

LawTransferCredit.propTypes = propTypes;

export default LawTransferCredit;
