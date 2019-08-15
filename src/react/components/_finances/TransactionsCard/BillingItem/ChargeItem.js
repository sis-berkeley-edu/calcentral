import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import formatDate from 'functions/formatDate';
import DisclosureChevron from 'react/components/DisclosureChevron';

import { CHARGE_PAID } from '../chargeStatuses';

import ItemDetails from './ItemDetails';
import ChargeAmountDue from './ChargeAmountDue';
import ChargeStatus from './ChargeStatus';
import ItemAmount from './ItemAmount';
import ItemUpdated from './ItemUpdated';

import './ChargeItem.scss';

const propTypes = {
  item: PropTypes.object,
  expanded: PropTypes.bool,
  onExpand: PropTypes.func,
  tab: PropTypes.string
};

import dueLabel from './dueLabel';

const MobileView = ({ item, expanded, onExpand }) => {
  return (
    <div className={`BillingItem BillingItem--charge BillingItem--mobile ${expanded ? 'BillingItem--expanded' : ''}`}
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
      <div className="BillingItem__status">
        { item.status !== CHARGE_PAID &&
          <ChargeStatus item={item} icon={true} />
        }
      </div>
      <div className="BillingItem__due">
        { item.status === CHARGE_PAID
          ? CHARGE_PAID
          : dueLabel(item.due_date)
        }
      </div>

      { expanded && <ItemDetails item={item} /> }

      <div className="TableColumn__chevron">
        <DisclosureChevron expanded={expanded}/>
      </div>
    </div>
  );
};
MobileView.propTypes = propTypes;

const DesktopView = ({ item, expanded, onExpand}) => {
  return (
    <div className={`BillingItem BillingItem--charge BillingItem--desktop ${expanded ? 'BillingItem--expanded' : ''}`}
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
        <ChargeStatus item={item} icon={true} />
      </div>
      <div className="TableColumn__due ChargeItem__due">
        <ChargeAmountDue item={item} icon={false} />
      </div>
      <div className="TableColumn__chevron">
        <DisclosureChevron expanded={expanded} />
      </div>

      { expanded && <ItemDetails item={item} /> }
    </div>
  );
};
DesktopView.propTypes = propTypes;

const ChargeItem = ({ item, expanded, onExpand}) => {
  return (
    <Fragment>
      <DesktopView item={item} expanded={expanded} onExpand={onExpand} />
      <MobileView item={item} expanded={expanded} onExpand={onExpand} />
    </Fragment>
  );
};
ChargeItem.propTypes = propTypes;

export default ChargeItem;
