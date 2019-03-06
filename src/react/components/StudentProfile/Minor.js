import React from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  minors: PropTypes.array
};

const Minor = (props) => (
  <tr>
    <th>{props.minors.length === 1 ? 'Minor' : 'Minors'}</th>
    <td>
      {props.minors.map((minors, index) => (
        <div key={index}>
          <div className="cc-text-light">{minors.college}</div>
          <div>{minors.minor}</div>
          {minors.minor.subPlan && <div className="cc-widget-profile-indent">{minors.minor.subPlan}</div>}
        </div>
      ))}
    </td>
  </tr>
);

Minor.propTypes = propTypes;

export default Minor;
