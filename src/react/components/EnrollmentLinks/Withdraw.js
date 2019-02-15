import React from 'react';
import PropTypes from 'prop-types';

import APILink from '../APILink';

const propTypes = { instruction: PropTypes.object.isRequired };

const Withdraw = ({ instruction }) => {
  const {
    role: enrollmentRole,
    enrollmentPeriod: enrollmentPeriods
  } = instruction;

  const link = instruction.links.addEnrolledClasses;

  if (enrollmentPeriods.length && enrollmentRole !== 'concurrent' && enrollmentRole !== 'law') {
    return (
      <APILink {...link} name="Withdraw" />
    );
  } else {
    return null;
  }
};

Withdraw.propTypes = propTypes;

export default Withdraw;
