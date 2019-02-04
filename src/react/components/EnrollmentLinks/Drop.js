import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../APILink';

const propTypes = { instruction: PropTypes.object.isRequired };

const Drop = (props) => {
  const {
    isClassScheduleAvailable: scheduleAvailable,
    isEndOfDropAddTimePeriod: endOfDropAdd,
    role: enrollmentRole
  } = props.instruction;

  const link = props.instruction.links.dropEnrolledClasses;

  if (scheduleAvailable && !endOfDropAdd && enrollmentRole !== 'concurrent') {
    return (
      <APILink {...link} name="Drop" />
    );
  } else {
    return null;
  }
};

Drop.propTypes = propTypes;

export default Drop;
