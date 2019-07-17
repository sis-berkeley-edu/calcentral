import React, { Fragment } from 'react';
import PropTypes from 'prop-types';

import formatCurrency from 'functions/formatCurrency';
import formatDate from 'functions/formatDate';
import 'icons/disc-inactive.svg';
import 'icons/disc-active.svg';
import 'icons/timeline-top-cap.svg';
import 'icons/timeline-bottom-cap.svg';
import 'icons/timeline-center.svg';
import './ItemAdjustment.scss';

import parseDate from 'date-fns/parse';

const GenericAdjustment = ({ className, description, posted }) => {
  return (
    <div className={`ItemAdjustment ${className}`}>
      <div className="ItemAdjustment__date">
        { formatDate(posted) }
      </div>
      <div className="ItemAdjustment__description">
        {description}
      </div>
    </div>
  );
};

GenericAdjustment.propTypes = {
  className: PropTypes.string.isRequired,
  description: PropTypes.string.isRequired,
  posted: PropTypes.instanceOf(Date).isRequired
};

const ItemAdjustment = ({ adjustment, isFirst, isLast, amount, itemType }) => {
  const posted = parseDate(adjustment.posted);
  const absoluteAmount = Math.abs(adjustment.amount);
  const correctedAmount = itemType === 'Charge' ? adjustment.amount : -adjustment.amount;
  const deltaBy = adjustment.amount > 0 ? 'Increased by' : 'Decreased by';

  if (isFirst) {
    return (
      <Fragment>
        <GenericAdjustment
          className="ItemAdjustment ItemAdjustment--first"
          posted={posted}
          description={`Current Amount: ${formatCurrency(amount)}`}
        />
        <GenericAdjustment
          className="ItemAdjustment ItemAdjustment--change"
          posted={posted}
          description={`${deltaBy} ${formatCurrency(absoluteAmount)}`}
        />
      </Fragment>
    );
  }

  if (isLast) {
    return (
      <GenericAdjustment className="ItemAdjustment ItemAdjustment--last"
        posted={posted}
        description={`Original Amount ${formatCurrency(correctedAmount)}`}
      />
    );
  }
  
  return (
    <GenericAdjustment className="ItemAdjustment ItemAdjustment--change"
      posted={posted}
      description={`${deltaBy} ${formatCurrency(absoluteAmount)}`}
    />
  );
};

ItemAdjustment.propTypes = {
  adjustment: PropTypes.object,
  isFirst: PropTypes.bool,
  isLast: PropTypes.bool,
  amount: PropTypes.number,
  itemType: PropTypes.string
};

export default ItemAdjustment;
