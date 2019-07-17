import React from 'react';
import PropTypes from 'prop-types';

import { termFromId } from 'react/helpers/terms';
import formatCurrency from 'functions/formatCurrency';

import './MoreDetails.scss';

const MoreDetails = ({ item: {
  term_id: termId,
  transaction_number: transactionNumber,
  balance
} }) => {
  const term = termFromId(termId);
  const unapplied = Math.abs(balance);

  return (
    <div className="MoreDetails">
      <ul>
        { transactionNumber &&
          <li>
            <strong>Transaction Number:</strong> {transactionNumber}
          </li>
        }

        { term &&
          <li>
            <strong>Term:</strong> {`${term.semester} ${term.year}`}
          </li>
        }

        { unapplied > 0 &&
          <li>
            <strong>Unapplied Amount:</strong> {formatCurrency(unapplied)}
          </li>
        }
      </ul>
    </div>
  );
};

MoreDetails.propTypes = {
  item: PropTypes.object
};

export default MoreDetails;
