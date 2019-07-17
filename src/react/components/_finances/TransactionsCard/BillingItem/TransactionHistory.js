import React from 'react';
import PropTypes from 'prop-types';

import ItemAdjustment from './ItemAdjustment';

import './TransactionHistory.scss';

const TransactionHistory = ({ item: { adjustments, type, amount: totalAmount } }) => {
  return (
    <div className="TransactionHistory">
      <h3>Transaction Amount History</h3>

      {adjustments.length > 1
        ? (
          <div className="ItemAdjustments">
            {adjustments.map((adjustment, index) => {
              const isFirst = index === 0;
              const isLast = index === adjustments.length - 1;

              return (
                <ItemAdjustment
                  key={index}
                  adjustment={adjustment}
                  itemType={type}
                  amount={totalAmount}
                  isFirst={isFirst}
                  isLast={isLast}
                />
              );
            })}
          </div>
        )
        : (
          <span className="NoChanges">No changes to show</span>
        )
      }
    </div>
  );
};

TransactionHistory.propTypes = {
  item: PropTypes.object
};

export default TransactionHistory;
