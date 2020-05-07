import React from 'react';
import PropTypes from 'prop-types';

import { parseISO } from 'date-fns';
import TimeCell from './TimeCell';

const Deadlines = ({ constraints: { deadlines = [] } = {}, programCode }) => {
  if (deadlines.length > 0) {
    const programIsEngineeringOrChem =
      programCode == 'UCOE' || programCode == 'UCCH';

    return (
      <>
        <h4
          className="cc-enrollment-card-headersub-title"
          style={{ marginTop: `10px` }}
        >
          Deadlines
        </h4>

        <div className="cc-table">
          <table>
            <tbody>
              {deadlines.map(deadline => {
                const addDeadline = parseISO(deadline.addDeadlineDatetime);
                const optionDeadline =
                  deadline.optionDeadlineDatetime &&
                  parseISO(deadline.optionDeadlineDatetime);

                return (
                  <React.Fragment key={deadline.session}>
                    <tr>
                      <td style={{ width: `33% ` }}>Add, drop, units</td>
                      <td style={{ width: `33% ` }}>
                        <TimeCell time={addDeadline} />
                      </td>
                      <td style={{ width: `33% ` }}></td>
                    </tr>
                    {programIsEngineeringOrChem ? (
                      <tr>
                        <td style={{ width: `33% ` }}>Grading option</td>
                        <td colSpan="2" style={{ fontSize: `12px` }}>
                          *Please refer to your college’s policy
                        </td>
                      </tr>
                    ) : (
                      optionDeadline && (
                        <tr>
                          <td style={{ width: `33% ` }}>Grading option</td>
                          <td style={{ width: `33% ` }}>
                            <TimeCell time={optionDeadline} />
                          </td>
                          <td style={{ width: `33% ` }}></td>
                        </tr>
                      )
                    )}
                  </React.Fragment>
                );
              })}
            </tbody>
          </table>
        </div>
      </>
    );
  }

  return null;
};

Deadlines.propTypes = {
  constraints: PropTypes.object,
  programCode: PropTypes.string,
};

export default Deadlines;
