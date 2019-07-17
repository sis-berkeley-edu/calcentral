import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import {
  CHARGE_PAID,
  CHARGE_OVERDUE,
  CHARGE_DUE,
  CHARGE_NOT_DUE
} from '../chargeStatuses';

import 'icons/overdue.svg';
import 'icons/due.svg';
import 'icons/not-due.svg';

import DueBadge from '../Badges/DueBadge';

const ChargeStatus = ({ item }) => {
  switch (item.status) {
    case CHARGE_PAID:
      return CHARGE_PAID;
    case CHARGE_OVERDUE:
    case CHARGE_DUE:
    case CHARGE_NOT_DUE:
      return (
        <Fragment>
          <DueBadge status={item.status}/>
          { item.amount_due !== item.amount && 'Partially Paid' }
        </Fragment>
      );
    default:
      return null;
  }
};

ChargeStatus.propTypes = {
  item: PropTypes.object
};

export default ChargeStatus;
