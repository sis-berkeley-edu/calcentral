import React from 'react';
import PropTypes from 'prop-types';

import formatCurrency from 'functions/formatCurrency';
import badgeStatusClassName from './badgeStatusClassName';

const DueAmountBadge = ({ amount, status }) => {
  const className = `Badge ${badgeStatusClassName(status)}`;

  return (
    <div className={className}>
      {formatCurrency(amount)}
    </div>
  );
};

DueAmountBadge.propTypes = {
  amount: PropTypes.number.isRequired,
  status: PropTypes.string.isRequired
};

export default DueAmountBadge;
