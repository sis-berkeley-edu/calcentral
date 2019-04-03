import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../../APILink';

const propTypes = {
  disabled: PropTypes.bool.isRequired,
  instruction: PropTypes.object.isRequired
};

const OptionsGradingEnd = (props) => {
  const {
    isEndOfDropAddTimePeriod: endOfDropAdd,
    role: enrollmentRole
  } = props.instruction;

  const link = props.instruction.links.gradeBase;
  const disabled = props.disabled;

  if (endOfDropAdd && enrollmentRole !== 'concurrent' && enrollmentRole !== 'law') {
    return (
      <APILink {...link} disabled={disabled} name="Change Grading Option" title="Change Grading Option" />
    );
  } else {
    return null;
  }
};

OptionsGradingEnd.propTypes = propTypes;

export default OptionsGradingEnd;
