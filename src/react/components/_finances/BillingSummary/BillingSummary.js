import PropTypes from 'prop-types';
import React from 'react';

import Balances from './Balances';
import HigherOneButtons from './HigherOneButtons';
import LearnMore from './LearnMore';
import WidgetBody from '../../Widget/WidgetBody';
import WidgetHeader from '../../Widget/WidgetHeader';

import '../../../stylesheets/box_model.scss';
import '../../../stylesheets/widgets.scss';

const propTypes = {
  billingDetails: PropTypes.bool.isRequired,
  canActOnFinances: PropTypes.bool.isRequired,
  finances: PropTypes.object,
  handleShowMore: PropTypes.func.isRequired,
  higherOneUrl: PropTypes.string.isRequired,
  learnMoreConfig: PropTypes.object.isRequired,
  learnMoreLinks: PropTypes.object.isRequired,
  showMore: PropTypes.bool.isRequired,
  trackAnalytics: PropTypes.func.isRequired,
  widgetConfig: PropTypes.object.isRequired
};

const BillingSummary = (props) => {
  const analyticsMetadata = {
    viewPdfStatement: {category: 'External link', action: 'Click', label: 'View PDF statement link'},
    makePayment: {category: 'External link', action: 'Click', label: 'Make payment link'}
  };

  return (
    <div className="cc-react-widget cc-widget">
      <WidgetHeader 
        title={props.widgetConfig.title}
        link={!props.billingDetails ? props.widgetConfig.link : null} />
      <WidgetBody widgetConfig={props.widgetConfig}>
        <Balances 
          amountDueNow={props.finances.amountDueNow}
          chargesNotYetDue={props.finances.chargesNotYetDue}
          pastDueAmount={props.finances.pastDueAmount} 
          totalUnpaidBalance={props.finances.totalUnpaidBalance} />
      </WidgetBody>
      <HigherOneButtons
        canActOnFinances={props.canActOnFinances}
        higherOneUrl={props.higherOneUrl}
        trackAnalytics={props.trackAnalytics}
        analyticsMakePayment={Object.values(analyticsMetadata.makePayment)}
        analyticsViewPdf={Object.values(analyticsMetadata.viewPdfStatement)} />
      <LearnMore
        handleShowMore={props.handleShowMore}
        learnMoreConfig={props.learnMoreConfig}
        learnMoreLinks={props.learnMoreLinks}
        showMore={props.showMore} />
    </div>
  );
};
BillingSummary.propTypes = propTypes;

export default BillingSummary;
