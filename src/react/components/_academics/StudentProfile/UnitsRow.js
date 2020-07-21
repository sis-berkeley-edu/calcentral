import React from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  name: PropTypes.string,
  value: PropTypes.oneOfType([PropTypes.number, PropTypes.string])
};

const UnitsRow = (props) => (
  <tr>
    <th>{props.name}</th>
    <td>{props.value}</td>
  </tr>
);

UnitsRow.propTypes = propTypes;

export default UnitsRow;
