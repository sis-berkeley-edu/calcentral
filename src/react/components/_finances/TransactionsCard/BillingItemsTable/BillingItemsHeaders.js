import React from 'react';
import PropTypes from 'prop-types';

import SortArrows from 'react/components/SortArrows';

import { BILLING_VIEW_PAYMENTS_AID } from '../billingItemViews';

import './BillingItemsHeaders.scss';

const BillingItemsHeaders = ({ tab, sortBy, setSortBy, sortOrder, setSortOrder }) => {
  return (
    <div className="BillingItemsHeaders">
      <div className="TableColumn__posted">
        <SortArrows
          label="Posted"
          column="postedOn"
          defaultOrder="DESC"
          sortBy={sortBy}
          sortOrder={sortOrder}
          setSortBy={setSortBy}
          setSortOrder={setSortOrder}
        />
      </div>
      <div className="TableColumn__description-amount">
        <div className="TableColumn__description">Description</div>
        <div className="TableColumn__amount">
          <SortArrows
            label="Transaction Amount"
            column="amount"
            defaultOrder="DESC"
            sortBy={sortBy}
            sortOrder={sortOrder}
            setSortBy={setSortBy}
            setSortOrder={setSortOrder}
          />
        </div>
      </div>
      <div className="TableColumn__status">
        { tab !== BILLING_VIEW_PAYMENTS_AID && 'Status' }
      </div>
      <div className="TableColumn__due">
        { tab !== BILLING_VIEW_PAYMENTS_AID &&
          <SortArrows
            label="Due"
            column="due"
            defaultOrder="ASC"
            sortBy={sortBy}
            sortOrder={sortOrder}
            setSortBy={setSortBy}
            setSortOrder={setSortOrder}
          />
        }
      </div>
      <div></div>
    </div>
  );
};

BillingItemsHeaders.propTypes = {
  tab: PropTypes.string,
  sortBy: PropTypes.string,
  setSortBy: PropTypes.func,
  sortOrder: PropTypes.string,
  setSortOrder: PropTypes.func
};

export default BillingItemsHeaders;
