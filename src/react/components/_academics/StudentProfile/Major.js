import React from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  majors: PropTypes.array
};

const Major = (props) => (
  <tr>
    <th>{props.majors.length === 1 ? 'Major' : 'Majors'}</th>
    <td>
      {props.majors.map((major, index) => (
        <div key={index}>
          <div className="cc-text-light">{major.college}</div>
          <div>{major.major}</div>
          {major.subPlan &&
            <div className="cc-widget-profile-indent">{major.subPlan}</div>
          }
        </div>
      ))}
    </td>
  </tr>
);

Major.propTypes = propTypes;

export default Major;
