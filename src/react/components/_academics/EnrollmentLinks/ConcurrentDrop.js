import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../../APILink';

const propTypes = {
  disabled: PropTypes.bool.isRequired,
  instruction: PropTypes.object.isRequired
};

const ConcurrentDrop = (props) => {
  const {
    isClassScheduleAvailable: scheduleAvailable,
    role: enrollmentRole
  } = props.instruction;

  const link = props.instruction.links.dropEnrolledClasses;
  const disabled = props.disabled;

  if (scheduleAvailable && enrollmentRole === 'concurrent') {
    return (
      <APILink {...link} disabled={disabled} name="Drop a Class" />
    );
  } else {
    return null;
  }
};

ConcurrentDrop.propTypes = propTypes;

export default ConcurrentDrop;
