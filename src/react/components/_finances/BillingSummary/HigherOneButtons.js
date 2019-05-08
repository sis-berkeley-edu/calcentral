import React from 'react';
import PropTypes from 'prop-types';

import '../../../stylesheets/billing_summary.scss';
import '../../../stylesheets/buttons.scss';
import '../../../stylesheets/widgets.scss';

const propTypes = {
  analyticsMakePayment: PropTypes.array.isRequired,
  analyticsViewPdf: PropTypes.array.isRequired,
  canActOnFinances: PropTypes.bool.isRequired,
  higherOneUrl: PropTypes.string.isRequired,
  trackAnalytics: PropTypes.func.isRequired
};

const HigherOneButtons = (props) => {
  return (
    <div className="cc-react-widget--padding-sides">
      <div className="higher-one">
        <a disabled={!props.canActOnFinances}
          href={props.higherOneUrl}
          className="cc-react-button cc-react-button--blue make-payment"
          target="_blank"
          rel="noopener noreferrer"
          onClick={() => props.trackAnalytics(...props.analyticsMakePayment)}>
          Make Payment
        </a>
        <a className="pdf-statements"
          disabled={!props.canActOnFinances}
          href={props.higherOneUrl}
          target="_blank"
          rel="noopener noreferrer"
          onClick={() => props.trackAnalytics(...props.analyticsViewPdf)}>
          View PDF Statement
        </a>
      </div>
    </div>
  );
};
HigherOneButtons.propTypes = propTypes;

export default HigherOneButtons;
