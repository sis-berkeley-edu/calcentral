import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../APILink';

const propTypes = { instruction: PropTypes.object.isRequired };

const ConcurrentOptions = (props) => {
  const {
    isClassScheduleAvailable: scheduleAvailable,
    role: enrollmentRole
  } = props.instruction;

  const link = props.instruction.links.gradeBase;

  if (scheduleAvailable && enrollmentRole === 'concurrent') {
    return (
      <APILink {...link} name="Edit Class Options" title="Edit Class Options" />
    );
  } else {
    return null;
  }
};

ConcurrentOptions.propTypes = propTypes;

export default ConcurrentOptions;
