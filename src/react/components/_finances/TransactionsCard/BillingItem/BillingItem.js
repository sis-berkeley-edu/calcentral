import React from 'react';
import PropTypes from 'prop-types';

import './BillingItem.scss';

import ChargeItem from './ChargeItem';
import PaymentItem from './PaymentItem';

import { chargeTypes, paymentTypes } from '../types';

const BillingItem = ({ tab, item, expanded, onExpand }) => {
  if (paymentTypes.has(item.type)) {
    return (
      <PaymentItem
        tab={tab}
        item={item}
        expanded={expanded}
        onExpand={onExpand}
      />
    );
  }

  if (chargeTypes.has(item.type)) {
    return (
      <ChargeItem
        item={item}
        expanded={expanded}
        onExpand={onExpand}
      />
    );
  }

  if (item < 0) {
    return (
      <PaymentItem
        tab={tab}
        item={item}
        expanded={expanded}
        onExpand={onExpand}
      />
    );
  } else if (item > 0) {
    return (
      <ChargeItem
        item={item}
        expanded={expanded}
        onExpand={onExpand}
      />
    );
  }

  if (item.due_date) {
    return (
      <ChargeItem
        item={item}
        expanded={expanded}
        onExpand={onExpand}
      />
    );
  }

  return (
    <PaymentItem
      tab={tab}
      item={item}
      expanded={expanded}
      onExpand={onExpand}
    />
  );
};

BillingItem.propTypes = {
  item: PropTypes.object,
  expanded: PropTypes.bool,
  onExpand: PropTypes.func,
  tab: PropTypes.string
};

export default BillingItem;
