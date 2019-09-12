import React from 'react';
import PropTypes from 'prop-types';

import RegistrationStatusIcon from 'React/components/_academics/RegistrationStatusIcon';

const RegistrationStatusItem = ({ termRegistration }) => (
  <div className="cc-launcher-status-description">
    <RegistrationStatusIcon severity={ termRegistration.status.severity } />
    <strong>{ termRegistration.termName }: </strong>
    { termRegistration.status.message }
  </div>
);

RegistrationStatusItem.propTypes = {
  termRegistration: PropTypes.object.isRequired
};

export default RegistrationStatusItem;
