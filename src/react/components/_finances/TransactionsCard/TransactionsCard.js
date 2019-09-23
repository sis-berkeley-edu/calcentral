import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { fetchBillingItems } from 'Redux/actions/billingActions';
import { fetchCarsData } from 'Redux/actions/carsDataActions';

import Card from 'React/components/Card';

import {
  BILLING_VIEW_ALL,
  BILLING_VIEW_UNPAID,
  BILLING_VIEW_PAYMENTS_AID
} from './billingItemViews';

import { chargeTypes, paymentTypes } from './types';

import UnappliedPaymentsInfo from './UnappliedPaymentsInfo';
import BillingItemFilters from './Filters/BillingItemFilters';
import BillingItemsTable from './BillingItemsTable/BillingItemsTable';
import DownloadButton from './DownloadButton';
import LegacyDataLink from './LegacyDataLink';

const billingItemForTab = tab => {
  return (billingItem) => {
    switch (tab) {
      case BILLING_VIEW_ALL:
        return true;
      case BILLING_VIEW_UNPAID:
        return chargeTypes.has(billingItem.type) && billingItem.amount_due > 0;
      case BILLING_VIEW_PAYMENTS_AID:
        return paymentTypes.has(billingItem.type);
    }
  };
};

const billingItemForTermId = termId => {
  return (billingItem) => {
    return termId === 'all' ? true : billingItem.term_id === termId;
  };
};

const billingItemTermIds = (billingItems) => {
  return [
    ...new Set(
      billingItems
      .map(item => item.term_id)
      .filter(item => item !== null)
      .sort((a, b) => parseInt(b) - parseInt(a))
    )
  ];
};

const billingItemsMatchingString = (search) => {
  return (item) => {
    if (search === '') {
      return true;
    }

    const corpus = `${item.description} ${item.type}`.toLowerCase();
    return corpus.includes(search.toLowerCase());
  };
};

import './TransactionsCard.scss';

export const TransactionsCard = ({ dispatch, billingItems, carsData }) => {
  useEffect(() => {
    dispatch(fetchBillingItems());
    dispatch(fetchCarsData());
  }, []);

  const [expanded, setExpanded] = useState(null);
  const [search, setSearch] = useState('');
  const [tab, setTab] = useState(BILLING_VIEW_UNPAID);
  const [termId, setTermId] = useState('all');

  const {
    items = [],
    isLoading: isBillingLoading = true,
    error: billingItemsError = false
  } = billingItems;

  const { isLoading: isCarsLoading = true, error: carsDataError } = carsData;

  const filteredItems = items
  .filter(billingItemForTab(tab))
  .filter(billingItemForTermId(termId))
  .filter(billingItemsMatchingString(search));

  const termIds = billingItemTermIds(items);
  const hasActiveFilters = termId !== 'all' || search !== '';

  const sum = (item, previous) => item + previous;
  const unappliedBalance = tab === BILLING_VIEW_PAYMENTS_AID
    ? Math.abs(filteredItems.map(item => item.balance).reduce(sum, 0))
    : 0;

  const error = billingItemsError || carsDataError
    ? { message: 'There is a problem displaying your billing information. Please try again soon.' }
    : false;

  return (
    <Card className="TransactionsCard"
      title="Transactions"
      loading={isBillingLoading || isCarsLoading}
      error={error}
      secondaryContent={<DownloadButton />}
    >
      <div className="TransactionCard__pretable">
        <BillingItemFilters tab={tab}
          setTab={setTab}
          termIds={termIds}
          termId={termId}
          setTermId={setTermId}
          search={search}
          setSearch={setSearch}
          setExpanded={setExpanded}
        />
        <LegacyDataLink unappliedBalance={unappliedBalance} />
        <UnappliedPaymentsInfo tab={tab} unappliedBalance={unappliedBalance} />
      </div>

      <BillingItemsTable items={filteredItems} tab={tab} hasActiveFilters={hasActiveFilters}
        expanded={expanded}
        setExpanded={setExpanded} />
    </Card>
  );
};

TransactionsCard.propTypes = {
  dispatch: PropTypes.func,
  billingItems: PropTypes.object,
  carsData: PropTypes.object
};

const mapStateToProps = ({ billingItems, carsData }) => ({ billingItems, carsData });

export default connect(mapStateToProps)(TransactionsCard);
