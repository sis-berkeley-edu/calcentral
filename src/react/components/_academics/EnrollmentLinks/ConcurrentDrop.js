import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../../APILink';

const propTypes = { instruction: PropTypes.object.isRequired };

const ConcurrentDrop = (props) => {
  const {
    isClassScheduleAvailable: scheduleAvailable,
    role: enrollmentRole
  } = props.instruction;

  const link = props.instruction.links.dropEnrolledClasses;

  if (scheduleAvailable && enrollmentRole === 'concurrent') {
    return (
      <APILink {...link} name="Drop a Class" />
    );
  } else {
    return null;
  }
};

ConcurrentDrop.propTypes = propTypes;

export default ConcurrentDrop;
