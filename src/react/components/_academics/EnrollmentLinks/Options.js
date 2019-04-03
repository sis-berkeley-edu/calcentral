import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../../APILink';

const propTypes = {
  disabled: PropTypes.bool.isRequired,
  instruction: PropTypes.object.isRequired
};

const Options = (props) => {
  const {
    isClassScheduleAvailable: scheduleAvailable,
    isEndOfDropAddTimePeriod: endOfDropAdd,
    role: enrollmentRole
  } = props.instruction;

  const link = props.instruction.links.gradeBase;
  const disabled = props.disabled;
  
  if (scheduleAvailable && !endOfDropAdd && enrollmentRole !== 'concurrent' && enrollmentRole !== 'law') {
    return (
      <APILink {...link} disabled={disabled} name="Options" title="Change Grading Option" />
    );
  } else {
    return null;
  }
};

Options.propTypes = propTypes;

export default Options;
