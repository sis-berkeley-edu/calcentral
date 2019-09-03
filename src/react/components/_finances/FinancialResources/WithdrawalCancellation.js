import React, { useState } from 'react';
import PropTypes from 'prop-types';
import APILink from 'React/components/APILink';
import HasAccessTo from './HasAccessTo';
import FinancialResourcesCategoryHeader from './FinancialResourcesCategoryHeader';
import './FinancialResources.scss';

const WithdrawalCancellation = ({ links, getLink, expanded }) => {
  const [isExpanded, setIsExpanded] = useState(expanded);

  return (
    <HasAccessTo linkNames={['leavingCal', 'withdrawCancel']} links={links}>
      <div
        className="FinancialResources__categoryContainer"
        onClick={() => setIsExpanded(!isExpanded)}
      >
        <FinancialResourcesCategoryHeader
          title="Withdrawal and Cancellation"
          expanded={isExpanded}
        />
        {isExpanded && (
          <ul className="FinancialResources">
            <HasAccessTo linkNames={['leavingCal']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('leavingCal', links)} />
                </li>
              )}
            </HasAccessTo>
            <HasAccessTo linkNames={['withdrawCancel']} links={links}>
              {links && (
                <li>
                  <APILink {...getLink('withdrawCancel', links)} />
                </li>
              )}
            </HasAccessTo>
          </ul>
        )}
      </div>
    </HasAccessTo>
  );
};

WithdrawalCancellation.propTypes = {
  expanded: PropTypes.bool,
  getLink: PropTypes.func,
  links: PropTypes.object,
};

export default WithdrawalCancellation;
