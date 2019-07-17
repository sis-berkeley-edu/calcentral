import React from 'react';
import PropTypes from 'prop-types';

import formatCurrency from 'functions/formatCurrency';

const UnappliedBalanceBadge = ({ amount }) => {
  if (amount < 0) {
    const string = `${formatCurrency(Math.abs(amount))} Unapplied`;
    return (
      <div className="Badge">{string}</div>
    );
  } else {
    return null;
  }
};

UnappliedBalanceBadge.propTypes = {
  amount: PropTypes.number
};

export default UnappliedBalanceBadge;
