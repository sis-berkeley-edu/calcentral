import React, { Fragment, useState } from 'react';
import PropTypes from 'prop-types';
import format from 'date-fns/format';
import addDays from 'date-fns/addDays';

import AppointmentDetails from './AppointmentDetails';

const AppointmentRow = ({ appointment }) => {
  const [expanded, setExpanded] = useState(false);

  return (
    <Fragment>
      <tr
        className="AppointmentRow--disclosure-row"
        onClick={() => setExpanded(!expanded)}
      >
        <td>{appointment.description}</td>
        <td>{format(addDays(appointment.startDate, 1), 'MM/DD/YY')}</td>
        <td>
          <div>{format(addDays(appointment.endDate, 1), 'MM/DD/YY')}</div>
        </td>
      </tr>
      {expanded && (
        <tr className="AppointmentRow--disclosed-row">
          <td colSpan="3">
            <AppointmentDetails appointment={appointment} />
          </td>
        </tr>
      )}
    </Fragment>
  );
};

AppointmentRow.propTypes = {
  appointment: PropTypes.object.isRequired,
};

export default AppointmentRow;
