import React, { Fragment, useEffect } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';

import { BILLING_VIEW_PAYMENTS_AID } from '../billingItemViews';
import formatDate from 'functions/formatDate';
import DisclosureChevron from 'react/components/DisclosureChevron';

import { fetchBillingItem } from 'redux/actions/billingActions'; 

import ItemAmount from './ItemAmount';
import PaymentDetails from './PaymentDetails';
import ItemUpdated from './ItemUpdated';
import UnappliedBalanceBadge from '../Badges/UnappliedBalanceBadge';

const propTypes = {
  item: PropTypes.object,
  expanded: PropTypes.bool,
  onExpand: PropTypes.func,
  tab: PropTypes.string
};

const MobileView = ({ tab, item, expanded, onExpand }) => {
  return (
    <div
      className={`BillingItem BillingItem--payment BillingItem--mobile ${expanded ? 'BillingItem--expanded' : ''}`}
      onClick={() => onExpand()}>
      <div className="BillingItem__posted">
        {formatDate(item.postedOn)}
      </div>
      <div className="BillingItem__type">
        {item.type}
      </div>
      <div className="BillingItem__description">
        {item.description}
      </div>
      <div className="BillingItem__amount">
        <ItemAmount amount={item.amount} />
      </div>
      <div className="TableColumn__status">
        { tab === BILLING_VIEW_PAYMENTS_AID &&
          <UnappliedBalanceBadge amount={item.balance} />
        }
      </div>

      { expanded && <PaymentDetails item={item} />}

      <div className="TableColumn__chevron">
        <DisclosureChevron expanded={expanded}/>
      </div>
    </div>
  );
};

MobileView.propTypes = propTypes;

const DesktopView = ({ tab, item, expanded, onExpand }) => {
  return (
    <div
      className={`BillingItem BillingItem--payment BillingItem--desktop ${expanded ? 'BillingItem--expanded' : ''}`}
      onClick={() => onExpand()}>
      <div className="TableColumn__posted">
        {formatDate(item.postedOn)}
      </div>
      <div className="TableColumn__description-amount">
        <div className="TableColumn__description">
          <div className="BillingItem__description">{item.description}</div>
          <div className="BillingItem__type">{item.type}</div>
        </div>
        <div className="TableColumn__amount">
          <ItemAmount amount={item.amount} />
          <ItemUpdated item={item} />
        </div>
      </div>
      <div className="TableColumn__status">
        { tab === BILLING_VIEW_PAYMENTS_AID &&
          <UnappliedBalanceBadge amount={item.balance} />
        }
      </div>
      <div className="TableColumn__chevron">
        <DisclosureChevron expanded={expanded} onClick={() => onExpand()} />
      </div>

      { expanded && <PaymentDetails item={item} />}
    </div>
  );
};

DesktopView.propTypes = propTypes;

const PaymentItem = ({ dispatch, ...props }) => {
  useEffect(() => {
    if (props.expanded) {
      dispatch(fetchBillingItem(props.item.id));
    }
  }, [props.expanded]);

  return (
    <Fragment>
      <MobileView {...props} />
      <DesktopView {...props} />
    </Fragment>
  );
};

PaymentItem.propTypes = propTypes;

export default connect()(PaymentItem);
