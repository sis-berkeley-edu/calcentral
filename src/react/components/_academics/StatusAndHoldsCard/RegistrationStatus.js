import React from 'react';
import PropTypes from 'prop-types';

import { DisclosureItem, DisclosureItemTitle } from 'React/components/DisclosureItem';
import StatusDisclosure from './StatusDisclosure';

const iconForSummary = (regStatusSummary) => {
  switch (regStatusSummary) {
    case 'Officially Registered':
    case 'You have access to campus services.':
      return 'fa-check-circle cc-icon-green';
    case 'Not Officially Registered':
    case 'Not Enrolled':
      return 'fa-exclamation-circle cc-icon-red';
    default:
      return 'fa-exclamation-triangle cc-icon-gold';
  }
};

const propTypes = {
  explanation: PropTypes.string,
  summary: PropTypes.string
};

const RegistrationStatus = ({ explanation, summary }) => {
  const iconClass = `cc-icon fa ${iconForSummary(summary)}`;

  if (explanation && summary) {
    return (
      <DisclosureItem>
        <DisclosureItemTitle>
          <i className={iconClass} style={{ marginRight: '4px' }}></i>
          { summary }
        </DisclosureItemTitle>
        <StatusDisclosure dangerouslySetInnerHTML={{__html: explanation }} />
      </DisclosureItem>
    );
  } else if (summary) {
    return (
      <div className='StatusItem'>
        <i className={iconClass} style={{ marginRight: '4px' }}></i>
        { summary }
      </div>
    );
  } else {
    return null;
  }
};

RegistrationStatus.propTypes = propTypes;

export default RegistrationStatus;
