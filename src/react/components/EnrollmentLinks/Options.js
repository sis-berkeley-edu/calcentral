import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../APILink';

const propTypes = { instruction: PropTypes.object.isRequired };

const Options = (props) => {
  const {
    isClassScheduleAvailable: scheduleAvailable,
    isEndOfDropAddTimePeriod: endOfDropAdd,
    role: enrollmentRole
  } = props.instruction;

  const link = props.instruction.links.gradeBase;
  
  if (scheduleAvailable && !endOfDropAdd && enrollmentRole !== 'concurrent' && enrollmentRole !== 'law') {
    return (
      <APILink {...link} name="Options" title="Change Grading Option" />
    );
  } else {
    return null;
  }
};

Options.propTypes = propTypes;

export default Options;
