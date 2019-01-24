import React from 'react';
import PropTypes from 'prop-types';

const formatGpa = (gpa) => parseFloat(gpa).toFixed(3);

const propTypes = {
  gpa: PropTypes.array
};

const GPA = (props) => (
  <tr>
    <th>Cumulative GPA</th>
    <td>
      {props.gpa.length === 1
        ? formatGpa(props.gpa[0].cumulativeGpa)
        : (
          <table>
            <tbody>
              {props.gpa.map(theGpa => (
                <tr key={theGpa.roleDescr}>
                  <th>{theGpa.roleDescr}</th>
                  <td>{formatGpa(theGpa.cumulativeGpaFloat)}</td>
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
