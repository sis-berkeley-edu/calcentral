import React, { useState } from 'react';
import PropTypes from 'prop-types';

import formatCurrency from 'functions/formatCurrency';
import './UnappliedPaymentsInfo.scss';

const UnappliedPaymentsInfo = ({ unappliedBalance }) => {
  const [showMore, setShowMore] = useState(false);

  if (unappliedBalance > 0) {
    const linkText = showMore ? 'Show less' : 'What is this?';

    return (
      <div className="UnappliedPaymentsInfo">
        <div className="UnappliedPaymentsInfo__header">
          <h2>Unapplied Payments and Aid: {formatCurrency(unappliedBalance)}</h2>
          <a onClick={() => setShowMore(!showMore)}>{linkText}</a>
        </div>
        {showMore && (
          <div className="UnappliedPaymentsInfo__more">
            Unapplied payments and aid do not help lower your Total Unpaid
            Balance. Payments or aid may be unapplied because there are no
            charges to pay at this time or because they are restricted to
            pay only certain types of charges. Either part or all of the
            payment or aid amount may be unapplied.
          </div>
        )}
      </div>
    );
  }

  return null;
};

UnappliedPaymentsInfo.propTypes = {
  unappliedBalance: PropTypes.number.isRequired
};

export default UnappliedPaymentsInfo;
