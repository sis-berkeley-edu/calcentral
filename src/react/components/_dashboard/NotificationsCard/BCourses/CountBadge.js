import React from 'react';
import PropTypes from 'prop-types';

const CountBadge = ({ count }) => {
  return (
    <span
      style={{
        backgroundColor: `#EEEEEE`,
        color: `black`,
        borderRadius: `10px`,
        fontSize: `10px`,
        padding: `2px 8px`,
        fontWeight: `bold`,
      }}
    >
      {count}
    </span>
  );
};

CountBadge.propTypes = {
  count: PropTypes.number,
};

export default CountBadge;
