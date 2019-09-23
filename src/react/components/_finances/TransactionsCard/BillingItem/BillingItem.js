import React from 'react';
import PropTypes from 'prop-types';

import './BillingItem.scss';

import ChargeItem from './ChargeItem';
import PaymentItem from './PaymentItem';

import { chargeTypes, paymentTypes } from '../types';

const BillingItem = ({ tab, item, expanded, onExpand, setExpanded }) => {
  if (paymentTypes.has(item.type)) {
    return (
      <PaymentItem
        tab={tab}
        item={item}
        expanded={expanded}
        onExpand={onExpand}
        setExpanded={setExpanded}
      />
    );
  }

  if (chargeTypes.has(item.type)) {
    return (
      <ChargeItem
        item={item}
        expanded={expanded}
        onExpand={onExpand}
        setExpanded={setExpanded}
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
        setExpanded={setExpanded}
      />
    );
  } else if (item > 0) {
    return (
      <ChargeItem
        item={item}
        expanded={expanded}
        onExpand={onExpand}
        setExpanded={setExpanded}
      />
    );
  }

  if (item.due_date) {
    return (
      <ChargeItem
        item={item}
        expanded={expanded}
        onExpand={onExpand}
        setExpanded={setExpanded}
      />
    );
  }

  return (
    <PaymentItem
      tab={tab}
      item={item}
      expanded={expanded}
      onExpand={onExpand}
      setExpanded={setExpanded}
    />
  );
};

BillingItem.propTypes = {
  item: PropTypes.object,
  expanded: PropTypes.bool,
  onExpand: PropTypes.func,
  setExpanded: PropTypes.func,
  tab: PropTypes.string
};

export default BillingItem;
