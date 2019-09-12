import React from 'react';
import PropTypes from 'prop-types';

import CNPStatusItem from './CNPStatusItem';
import RegistrationStatusItem from './RegistrationStatusItem';

const RegistrationStatusItemsForTerm = ({ termRegistration }) => {
  if (termRegistration.isInPopover) {
    return (
      <li className="cc-popover-item">
        <a href="/academics">
          <RegistrationStatusItem termRegistration={termRegistration} />
          <CNPStatusItem termRegistration={termRegistration} />
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
