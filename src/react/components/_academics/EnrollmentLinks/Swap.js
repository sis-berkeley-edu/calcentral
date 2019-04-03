import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../../APILink';

import { hasRoleInList } from '../../../helpers/roles';

const propTypes = {
  disabled: PropTypes.bool.isRequired,
  instruction: PropTypes.object.isRequired,
  currentRoles: PropTypes.array.isRequired
};

const Swap = (props) => {
  const {
    isClassScheduleAvailable: scheduleAvailable,
    isEndOfDropAddTimePeriod: endOfDropAdd,
    role: enrollmentRole
  } = props.instruction;

  const link = props.instruction.links.swapEnrolledClasses;
  const disabled = props.disabled;

  if (!hasRoleInList('law', props.currentRoles) && scheduleAvailable && !endOfDropAdd && enrollmentRole !== 'concurrent') {
    return (
      <APILink {...link} disabled={disabled} name="Swap" />
    );
  } else {
    return null;
  }
};

Swap.propTypes = propTypes;

export default Swap;
