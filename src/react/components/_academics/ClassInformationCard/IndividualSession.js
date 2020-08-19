import React from 'react';
import PropTypes from 'prop-types';

export default function IndividualSession({
  session: { date, time, roomNumber, buildingName },
}) {
  return (
    <div>
      {[date, time, roomNumber, buildingName].filter(item => item).join(' - ')}
    </div>
  );
}

IndividualSession.propTypes = {
  session: PropTypes.shape({
    date: PropTypes.string,
    time: PropTypes.string,
    roomNumber: PropTypes.string,
    buildingName: PropTypes.string,
  }),
};
