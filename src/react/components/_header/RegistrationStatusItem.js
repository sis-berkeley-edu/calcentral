import React from 'react';
import PropTypes from 'prop-types';

import RegistrationStatusIcon from 'React/components/_academics/RegistrationStatusIcon';

const RegistrationStatusItem = ({ registrationStatus, termName }) => {
  if (registrationStatus === null) {
    return null;
  }

  return (
    <div className="cc-launcher-status-description">
      <RegistrationStatusIcon severity={ registrationStatus.severity } />
      <strong>{ termName }: </strong>
      { registrationStatus.message }
    </div>
  );
};

RegistrationStatusItem.propTypes = {
  registrationStatus: PropTypes.object,
  termName: PropTypes.string
};

export default RegistrationStatusItem;
