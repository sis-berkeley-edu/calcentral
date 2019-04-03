import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../../APILink';

const propTypes = {
  disabled: PropTypes.bool.isRequired,
  instruction: PropTypes.object.isRequired
};

const ConcurrentOptions = (props) => {
  const {
    isClassScheduleAvailable: scheduleAvailable,
    role: enrollmentRole
  } = props.instruction;

  const link = props.instruction.links.gradeBase;
  const disabled = props.disabled;

  if (scheduleAvailable && enrollmentRole === 'concurrent') {
    return (
      <APILink {...link} disabled={disabled} name="Edit Class Options" title="Edit Class Options" />
    );
  } else {
    return null;
  }
};

ConcurrentOptions.propTypes = propTypes;

export default ConcurrentOptions;
