import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../APILink';

const propTypes = { instruction: PropTypes.object.isRequired };

const Add = (props) => {
  const {
    isClassScheduleAvailable: scheduleAvailable,
    isEndOfDropAddTimePeriod: endOfDropAdd,
    role: enrollmentRole
  } = props.instruction;

  const link = props.instruction.links.addEnrolledClasses;

  if (scheduleAvailable && !endOfDropAdd && enrollmentRole !== 'concurrent') {
    return (
      <APILink {...link} name="Add" />
    );
  } else {
    return null;
  }
};

Add.propTypes = propTypes;

export default Add;
