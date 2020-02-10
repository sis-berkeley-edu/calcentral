import React from 'react';
import PropTypes from 'prop-types';

const NoMessages = ({ year }) => {
  const style = { padding: `15px`, lineHeight: `1.6` };

  return (
    <div style={style}>
      {year
        ? `You have no messages for ${parseInt(year) - 1}-${year}`
        : `You have no notifications at this time.`}
    </div>
  );
};

NoMessages.propTypes = {
  year: PropTypes.string,
};

export default NoMessages;
