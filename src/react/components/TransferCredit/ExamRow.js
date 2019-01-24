import React from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  name: PropTypes.string,
  value: PropTypes.number
};

const ExamRow = ({ name, value }) => {
  if (value > 0) {
    return (
      <tr>
        <td>{name}</td>
        <td className="cc-table-right">{value.toFixed(3)}</td>
      </tr>
    );
  } else {
    return null;
  }
};

ExamRow.propTypes = propTypes;

export default ExamRow;
