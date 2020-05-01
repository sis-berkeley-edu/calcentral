import React from 'react';
import PropTypes from 'prop-types';
import { format } from 'date-fns';

const TimeCell = ({ time }) => {
  if (time) {
    const formattedDate = format(time, 'MMM d');
    const formattedTime = format(time, 'h:mma');

    return (
      <div
        style={{
          maxWidth: `110px`,
          display: `flex`,
          justifyContent: 'space-between',
          paddingRight: `10px`,
        }}
      >
        <span>{formattedDate}</span>
        <span>{formattedTime.toLowerCase()}</span>
      </div>
    );
  }

  return null;
};

TimeCell.propTypes = {
  time: PropTypes.instanceOf(Date),
};

export default TimeCell;
