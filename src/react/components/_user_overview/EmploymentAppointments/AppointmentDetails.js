import React from 'react';
import PropTypes from 'prop-types';

const propTypes = {
  appointment: PropTypes.object.isRequired
};

const AppointmentDetails = ({
  appointment
}) => {
  const {
    compensation,
    distributionPercentage,
    unit,
    step,
    jobCode,
    account,
    fundCode,
    departmentId,
    programCode,
    businessUnit,
    chartfield1,
    chartfield2
  } = appointment;

  const chartString = `${businessUnit}-${account}-${fundCode}-${departmentId}-${programCode}-${chartfield1}-${chartfield2}`;

  return (
    <ul>
      <li><strong>Job Code:</strong> {jobCode}</li>
      <li><strong>Unit:</strong> {unit}</li>
      <li><strong>Step:</strong> {step}</li>
      <li><strong>Pay:</strong> ${parseFloat(compensation).toFixed(2)}</li>
      <li><strong>Distribution:</strong> {parseFloat(distributionPercentage).toFixed(2)}%</li>
      <li><strong>Chart String:</strong> {chartString}</li>
    </ul>
  );
};

AppointmentDetails.propTypes = propTypes;

export default AppointmentDetails;
