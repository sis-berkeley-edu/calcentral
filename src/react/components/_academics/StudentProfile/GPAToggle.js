import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import { formatGpaCumulative } from 'React/helpers/gpa';

const propTypes = {
  gpa: PropTypes.array.isRequired,
  currentlySummerVisitor: PropTypes.bool
};

const GPAToggle = ({ gpa, currentlySummerVisitor }) => {
  const hasNonLawRole = gpa.find(item => item.role !== 'law');

  const [visible, setVisible] = useState(false);

  if (!currentlySummerVisitor && hasNonLawRole) {
    return (
      <tr>
        <th>GPA</th>
        <td>
          {visible
            ? (
              <div>
                {gpa.length === 1
                  ? formatGpaCumulative(gpa[0])
                  : (
                    <table className="student-profile__subtable">
                      <tbody>
                        {gpa.map(theGpa => (
                          <tr key={theGpa.roleDescr}>
                            <th>{theGpa.roleDescr}</th>
                            <td>{formatGpaCumulative(theGpa)}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  )
                }
                (<button onClick={() => setVisible(false)} className="cc-button-link">
                  Hide
                </button>)
              </div>
            )
            : (
              <button onClick={() => setVisible(true)} className="cc-button-link">
                Show GPA
              </button>
            )
          }
        </td>
      </tr>
    );
  } else {
    return null;
  }
};

GPAToggle.propTypes = propTypes;

const mapStateToProps = ({
  myAcademics = {},
  myStatus: {
    academicRoles: {
      current: {
        summerVisitor
      } = {}
    } = {}
  } = {}
}) => {
  const {
    gpaUnits: {
      gpa
    } = {}
  } = myAcademics;

  return {
    gpa: (gpa || []),
    currentlySummerVisitor: summerVisitor
  };
};

export default connect(mapStateToProps)(GPAToggle);
