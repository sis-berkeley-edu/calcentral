import React from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  gpa: PropTypes.array
};

const formatGpaCumulative = (gpa) => {
  if (gpa.role === 'law') {
    return 'N/A';
  } else {
    return parseFloat(gpa.cumulativeGpa).toFixed(3);
  }
};

const GPA = (props) => (
  <tr>
    <th>Cumulative GPA</th>
    <td>
      {props.gpa.length === 1
        ? formatGpaCumulative(props.gpa[0])
        : (
          <table className="student-profile__subtable">
            <tbody>
              {props.gpa.map(theGpa => (
                <tr key={theGpa.roleDescr}>
                  <th>{theGpa.roleDescr}</th>
                  <td>{formatGpaCumulative(theGpa)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )
      }
    </td>
  </tr>
);

GPA.propTypes = propTypes;

export default GPA;
