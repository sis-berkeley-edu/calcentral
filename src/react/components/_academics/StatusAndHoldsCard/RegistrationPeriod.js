import React from 'react';
import PropTypes from 'prop-types';

import RegistrationStatus from './RegistrationStatus';
import CNPWarning from './CNPWarning';

const propTypes = {
  period: PropTypes.object.isRequired,
};

const RegistrationPeriod = ({ period }) => {
  const showPeriod = period.showCnp || period.regStatus;

  if (showPeriod) {
    return (
      <div className="RegistrationPeriod">
        <h4>
          {period.semester} {period.year}
        </h4>
        <RegistrationStatus {...period.regStatus} />
        <CNPWarning registration={period} />
      </div>
    );
  } else {
    return null;
  }
};

RegistrationPeriod.propTypes = propTypes;

export default RegistrationPeriod;
