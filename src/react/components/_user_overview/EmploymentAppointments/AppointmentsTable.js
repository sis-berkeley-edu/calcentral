import React from 'react';
import PropTypes from 'prop-types';

import './AppointmentsTable.scss';
import AppointmentRow from './AppointmentRow';

const AppointmentsTable = ({ appointments, showFirst, showAll }) => {
  const appointmentsToShow = showAll ? appointments : appointments.slice(0, showFirst);

  if (appointmentsToShow.length) {
    return (
      <table className="AppointmentsTable">
        <thead>
          <tr>
            <th>Position</th>
            <th>Start</th>
            <th>End</th>
          </tr>
        </thead>
        <tbody>
          { appointmentsToShow.map((appointment, index) => (
            <AppointmentRow key={index} appointment={appointment} />
          ))}
        </tbody>
      </table>
    );
  } else {
    return null;
  }
};

AppointmentsTable.propTypes = {
  appointments: PropTypes.array.isRequired,
  showFirst: PropTypes.number.isRequired,
  showAll: PropTypes.bool.isRequired
};

export default AppointmentsTable;
