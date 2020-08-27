import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import { CHARGE_PAID } from '../chargeStatuses';

import DueBadge from '../Badges/DueBadge';

const PartiallyPaidStatus = () => (
  <div className="PartiallyPaid">Partially Paid</div>
);

const ChargeStatus = ({ item }) => {
  if (item.status === CHARGE_PAID) {
    if (item.amount === 0) {
      return null;
    } else {
      return CHARGE_PAID;
    }
  }

  return (
    <Fragment>
      <DueBadge status={item.status} />
      {item.amount_due !== item.amount && <PartiallyPaidStatus />}
    </Fragment>
  );
};

ChargeStatus.propTypes = {
  item: PropTypes.object,
};

export default ChargeStatus;
