import React from 'react';
import PropTypes from 'prop-types';

import CNPStatusItem from './CNPStatusItem';
import RegistrationStatusItem from './RegistrationStatusItem';

const RegistrationStatusItemsForTerm = ({
  termRegistration
}) => {
  if (termRegistration.inPopover) {
    return (
      <li className="cc-popover-item">
        <a href="/academics">
          <RegistrationStatusItem
            registrationStatus={termRegistration.registrationStatus}
            termName={termRegistration.termName}
          />

          <CNPStatusItem cnpStatus={termRegistration.cnpStatus} />
        </a>
      </li>
    );
  }

  return null;
};

RegistrationStatusItemsForTerm.propTypes = {
  termRegistration: PropTypes.object
};

export default RegistrationStatusItemsForTerm;
