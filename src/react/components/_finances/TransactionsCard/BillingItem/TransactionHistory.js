import React, { useState } from 'react';
import PropTypes from 'prop-types';
import parseDate from 'date-fns/parse';

import ItemAdjustment, { GenericAdjustment } from './ItemAdjustment';
import formatCurrency from 'functions/formatCurrency';

import './TransactionHistory.scss';
const TransactionHistory = ({ item: { adjustments, amount: itemAmount } }) => {
  const [showAll, setShowAll] = useState(false);

  const first = adjustments[0];
  const original = adjustments[adjustments.length - 1];
  const changes = [...adjustments.slice(0, -1)];
  const firstFour = [...changes.slice(0, 4)];
  const nextFour = [...changes.slice(4, 8)];
  const tooMany = changes.length > 8;

  return (
    <div className="TransactionHistory">
      <h3>Transaction Amount History</h3>

      {adjustments.length > 1
        ? (
          <div className="ItemAdjustments">
            <GenericAdjustment className="ItemAdjustment--first"
              posted={parseDate(first.posted)}
              description={`Current Amount: ${formatCurrency(Math.abs(itemAmount))}`}
            />

            {firstFour.map((adjustment, index) => <ItemAdjustment key={index} adjustment={adjustment} />)}

            {nextFour.length > 0 &&
              <li
                className="ItemAdjustment ItemAdjustment--show-more"
                onClick={() => setShowAll(!showAll)}>
                { showAll ? 'Show Less' : 'Show More' }
              </li>
            }

            {showAll && nextFour.map((adjustment, index) => <ItemAdjustment key={index} adjustment={adjustment} />)}
            {showAll && tooMany &&
              <li
                className="ItemAdjustment ItemAdjustment--too-many">
                Too many earlier changes to show
              </li>
            }

            <GenericAdjustment className="ItemAdjustment--last"
              posted={parseDate(original.posted)}
              description={`Original Amount: ${formatCurrency(Math.abs(original.amount))}`}
            />
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
