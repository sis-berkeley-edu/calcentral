import React from 'react';
import PropTypes from 'prop-types';

import formatCurrency from 'functions/formatCurrency';
import formatDate from 'functions/formatDate';

import './ItemPayment.scss';
import parseDate from 'date-fns/parse';

const ItemPayment = ({ payment }) => {
  return (
    <li className="ItemPayment">
      <div className="flex">
        <div className="ItemPayment__description">
          <div>{ payment.description }</div>
          <div className="ItemPayment__paid-on">
            Paid on { formatDate(parseDate(payment.effective_date)) }
          </div>
        </div>
        <div className="ItemPayment__amount">
          { formatCurrency(Math.abs(payment.amount_paid)) }
        </div>
      </div>
    </li>
  );
};
ItemPayment.propTypes = {
  payment: PropTypes.object
};

export default ItemPayment;
