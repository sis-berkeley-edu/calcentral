import React from 'react';
import PropTypes from 'prop-types';

import RegistrationStatus from './RegistrationStatus';
import CNPWarning from './CNPWarning';
import CalGrantStatusItem from './CalGrantStatusItem';

const propTypes = {
  period: PropTypes.object.isRequired
};

const RegistrationPeriod = ({ period }) => (
  <div className="RegistrationPeriod">
    <h4>{ period.semester } { period.year }</h4>
    <CNPWarning registration={period} />
    <RegistrationStatus {...period.regStatus} />
    <CalGrantStatusItem acknowledgement={period.calGrantAcknowledgement} />
  </div>
);

RegistrationPeriod.propTypes = propTypes;

export default RegistrationPeriod;
