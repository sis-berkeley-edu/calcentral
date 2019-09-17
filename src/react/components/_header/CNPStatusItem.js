import React from 'react';
import PropTypes from 'prop-types';

import RegistrationStatusIcon from 'React/components/_academics/RegistrationStatusIcon';

const CNPStatusItem = ({ cnpStatus }) => {
  if (cnpStatus.inPopover) {
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
  }

  return null;
};

CNPStatusItem.propTypes = {
  cnpStatus: PropTypes.object
};

export default CNPStatusItem;
