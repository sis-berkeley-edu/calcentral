import React from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  levels: PropTypes.array
};

const Levels = ({levels}) => (
  <tr>
    <th>Level</th>
    <td>
      {levels.map((level, index) => (
        <div key={index}>
          <span>{level}</span>
        </div>
      ))}
    </td>
  </tr>
);

Levels.propTypes = propTypes;

export default Levels;
