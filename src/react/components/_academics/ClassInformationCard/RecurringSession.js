import React from 'react';
import PropTypes from 'prop-types';

export default function RecurringSession({
  session: { schedule, roomNumber, buildingName },
}) {
  return (
    <div>
      {[schedule, roomNumber, buildingName].filter(item => item).join(' - ')}
    </div>
  );
}

RecurringSession.propTypes = {
  session: PropTypes.shape({
    schedule: PropTypes.string,
    roomNumber: PropTypes.string,
    buildingName: PropTypes.string,
  }),
};
