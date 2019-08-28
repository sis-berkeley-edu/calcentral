import React from 'react';
import PropTypes from 'prop-types';

import RegistrationStatusIcon from 'React/components/_academics/RegistrationStatusIcon';

const CNPStatusItem = ({ termRegistration: { cnpStatus = {} } }) => {
  if (cnpStatus.message === '') {
    return null;
  }

  return (
    <div className="cc-launcher-status-description">
      <RegistrationStatusIcon severity={ cnpStatus.severity } />

      { cnpStatus.severity === 'warning' &&
        (
          <strong>Warning: </strong>
        )
      }

      { cnpStatus.message }
    </div>
  );
};

CNPStatusItem.propTypes = {
  termRegistration: PropTypes.object.isRequired
};

export default CNPStatusItem;
