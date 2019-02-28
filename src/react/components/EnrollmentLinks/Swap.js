import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../APILink';

import { hasRoleInList } from '../../helpers/roles';

const propTypes = {
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

  if (!hasRoleInList('law', props.currentRoles) && scheduleAvailable && !endOfDropAdd && enrollmentRole !== 'concurrent') {
    return (
      <APILink {...link} name="Swap" />
    );
  } else {
    return null;
  }
};

Swap.propTypes = propTypes;

export default Swap;
