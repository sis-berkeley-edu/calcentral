import React from 'react';
import PropTypes from 'prop-types';
import { format, utcToZonedTime } from 'date-fns-tz';

const TimeCell = ({ time }) => {
  if (time) {
    const zonedTime = utcToZonedTime(time, 'America/Los_Angeles');
    const formattedDate = format(zonedTime, 'MMM d');
    const formattedTime = format(zonedTime, 'h:mma');

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
