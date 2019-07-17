import React from 'react';
import PropTypes from 'prop-types';

import formatCurrency from 'functions/formatCurrency';
import Spinner from 'react/components/Spinner';
import ItemPayment from './ItemPayment';

import 'icons/warning.svg';
import './ChargesPaid.scss';

const ItemPayments = ({ children }) => (<ol>{children}</ol>);
ItemPayments.propTypes = {
  children: PropTypes.node
};

const ChargesPaidTab = ({ item }) => {
  const payments = item.payments || [];
  const { isLoadingPayments: loading, loadingPaymentsError: error } = item;

  if (loading) {
    return (
      <div className='ChargesPaid ChargesPaid--loading'>
        <Spinner />
      </div>
    );
  }

  if (error) {
    return (
      <div className='ChargesPaid ChargesPaid--error'>
        <img src="/assets/images/warning.svg" />
        There is a problem displaying this information. Please try again soon.
      </div>
    );
  }

  return (
    <div className='ChargesPaid'>
      <h3>Charges paid by this transactions</h3>

      {payments.length > 0
        ? (
          <ItemPayments>
            { payments.map((payment, index) => (
              <ItemPayment key={index} payment={payment} />
            ))}
          </ItemPayments>
        )
        : 'No charges have been paid at this time'
      }

      { item.balance !== 0 &&
        <div style={{ textAlign: `right`, marginTop: `18px` }}>
          Unapplied Balance: 
          <span style={{ marginLeft: `5px` }}>
            { formatCurrency(Math.abs(item.balance)) }
          </span>
        </div>
      }
    </div>
  );
};
ChargesPaidTab.propTypes = {
  item: PropTypes.object
};

export default ChargesPaidTab;
