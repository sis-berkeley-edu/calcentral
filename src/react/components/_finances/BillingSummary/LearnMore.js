import React from 'react';
import PropTypes from 'prop-types';

import CampusSolutionsLinkContainer from '../../CampusSolutionsLink/CampusSolutionsLinkContainer';
import ShowMore from '../../ShowMore';
import WidgetBody from '../../Widget/WidgetBody';

import '../../../stylesheets/billing_summary.scss';
import '../../../stylesheets/widgets.scss';

const propTypes = {
  handleShowMore: PropTypes.func.isRequired,
  learnMoreConfig: PropTypes.object.isRequired,
  learnMoreLinks: PropTypes.object.isRequired,
  showMore: PropTypes.bool.isRequired
};

const renderCsLink = (link) => {
  if (link) {
    return (
      <span>
        Learn more about <CampusSolutionsLinkContainer linkObj={link} />.
      </span>
    );
  } else {
    return null;
  }
};

const expandedView = (config, links) => {
  return (
    <WidgetBody widgetConfig={config}>
      <div className="cc-react-widget--padding-sides learn-more">
        <strong>Due Now</strong>
        <p>All charges with a due date of today or before today. Due Now also includes Overdue charges. {renderCsLink(links.studentBilling)}</p>
        <strong>Not Yet Due</strong>
        <p>All charges with a due date of tomorrow or any date in the future. {renderCsLink(links.studentBilling)}</p>
        <strong>Overdue</strong>
        <p>All charges with a due date before today. Overdue charges can result in late fees and enrollment cancellation. {renderCsLink(links.delinquentAccounts)}</p>
        <strong>Making Payments</strong>
        <p>Make Payment links to the student payment portal where you can pay your bill. {renderCsLink(links.makingPayments)}</p>
        <strong>View PDF Statement</strong>
        <p>Links to PDF statements that are easy to download or print.</p>
      </div>
    </WidgetBody>
  );
};

const text = 'Learn more about Billing';

const LearnMore = (props) => {
  return (
    <ShowMore 
      clickHandler={props.handleShowMore}
      expanded={props.showMore}
      text={text}
      view={expandedView(props.learnMoreConfig, props.learnMoreLinks)} />
  );
};
LearnMore.propTypes = propTypes;

export default LearnMore;
