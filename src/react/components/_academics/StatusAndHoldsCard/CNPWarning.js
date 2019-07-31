import React from 'react';
import PropTypes from 'prop-types';

import { DisclosureItem, DisclosureItemTitle } from 'React/components/DisclosureItem';
import StatusDisclosure from './StatusDisclosure';

var iconForSummary = ({
  positiveIndicators,
  termFlags: { pastFinancialDisbursement }
}) => {
  const indicatorTypes = new Set(positiveIndicators.map((ind) => ind.type.code));

  if (indicatorTypes.has('+R99')) {
    return 'fa-check-circle cc-icon-green';
  } else if (indicatorTypes.has('+ROP')) {
    return 'fa-exclamation-triangle cc-icon-gold';
  } else if (pastFinancialDisbursement) {
    return 'fa-exclamation-circle cc-icon-red';
  } else {
    return 'fa-exclamation-triangle cc-icon-gold';
  }
};

const propTypes = {
  explanation: PropTypes.string,
  summary: PropTypes.string
};

const CNPWarning = ({ registration }) => {
  const iconClass = `cc-icon fa ${iconForSummary(registration)}`;
  const { hasCNPWarning } = registration;

  if (hasCNPWarning) {
    const { cnpStatus: { explanation, summary } = {} } = registration;
    return (
      <DisclosureItem>
        <DisclosureItemTitle>
          <i className={iconClass} style={{ marginRight: '4px' }}></i>
          { summary }
        </DisclosureItemTitle>
        <StatusDisclosure dangerouslySetInnerHTML={{__html: explanation }} />
      </DisclosureItem>
    );
  } else {
    return null;
  }
};

CNPWarning.propTypes = propTypes;

export default CNPWarning;
