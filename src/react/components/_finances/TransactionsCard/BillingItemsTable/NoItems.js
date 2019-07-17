import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import {
  BILLING_VIEW_UNPAID
} from '../billingItemViews';

const Message = ({ tab, hasActiveFilters }) => {
  if (tab === BILLING_VIEW_UNPAID && !hasActiveFilters) {
    return 'You do not have an Unpaid Balance at this time';
  }

  if (hasActiveFilters) {
    return (
      <Fragment>
        No transactions to show.<br />
        Try adjusting your filter or search to find transactions.
      </Fragment>
    );
  }

  return 'No transactions to show at this time.';
};

const NoItems = ({ tab, hasActiveFilters }) => {
  return (
    <div style={{ paddingTop: '60px', textAlign: 'center', color: `#666` }}>
      <Message tab={tab} hasActiveFilters={hasActiveFilters} />
    </div>
  );
};
NoItems.propTypes = {
  tab: PropTypes.string.isRequired,
  hasActiveFilters: PropTypes.bool
};

export default NoItems;
