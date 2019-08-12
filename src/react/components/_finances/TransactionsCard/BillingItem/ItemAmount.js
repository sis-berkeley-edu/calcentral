import React from 'react';
import PropTypes from 'prop-types';

import formatCurrency from 'functions/formatCurrency';
import './ItemAmount.scss';

const ItemAmount = ({ amount }) => {
  const className = `ItemAmount ${amount < 0 ? 'ItemAmount--payment' : ''}`;

  return (
    <div className={className}>
      {formatCurrency(amount)}
    </div>
  );
};

ItemAmount.propTypes = {
  amount: PropTypes.number
};

export default ItemAmount;
